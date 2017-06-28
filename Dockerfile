FROM ubuntu:16.04

ENV GOPATH /root/go
RUN mkdir /root/go

# Dependencies
RUN apt-get update && apt-get install -y software-properties-common apt-transport-https wget \
    libglib2.0-dev gnupg e2fslibs-dev libgpg-error-dev libgpgme11-dev libassuan-dev \
    git gettext-base python3-pip vim gpgsm libfuse-dev fuse bison dh-autoreconf \
    liblzma-dev tmux
RUN apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-yakkety main' && \
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    apt-get update && apt-get install -y docker-engine

# Install Go 1.8 and ostree (missing in Ubuntu 16.04, needed by the server)
RUN mkdir /root/sources && \
    cd /root/sources && \
    wget https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz && \
    tar -zxf go1.8.3.linux-amd64.tar.gz && \
    mv go /usr/local && \
    git clone https://github.com/ostreedev/ostree.git && \
    cd ostree && \
    env NOCONFIGURE=1 ./autogen.sh && \
    ./configure --prefix=/usr/local && \
    make -j 4 && \ 
    make install && \
    ldconfig                                                              

# Go-get bblfsh's components and assign the right permissions
RUN cd /root && \
    export PATH="/root/go/bin:/usr/local/go/bin:${PATH}" && \
    go get github.com/bblfsh/sdk/... && \
    go get github.com/bblfsh/python-driver/... && \
    go get github.com/bblfsh/java-driver/... && \
    go get github.com/bblfsh/server/... && \
    cd $GOPATH/src/github.com/bblfsh/server/cmd/bblfsh && \
    go build && \

    mkdir $GOPATH/src/github.com/bblfsh/python-driver/build && \
    mkdir -p $GOPATH/src/github.com/bblfsh/python-driver/.sdk/make && \
    mkdir -p $GOPATH/src/github.com/bblfsh/python-driver/.sdk/etc && \
    touch $GOPATH/src/github.com/bblfsh/python-driver/.sdk/make/manifest.mk && \
    touch $GOPATH/src/github.com/bblfsh/python-driver/.sdk/etc/run.sh && \

    mkdir $GOPATH/src/github.com/bblfsh/java-driver/build && \
    mkdir -p $GOPATH/src/github.com/bblfsh/java-driver/.sdk/make && \
    mkdir -p $GOPATH/src/github.com/bblfsh/java-driver/.sdk/etc && \
    touch $GOPATH/src/github.com/bblfsh/java-driver/.sdk/make/manifest.mk && \
    touch $GOPATH/src/github.com/bblfsh/java-driver/.sdk/etc/run.sh && \

    chown -R 1000 $GOPATH/src/github.com/bblfsh/python-driver && \
    chown -R 1000 $GOPATH/src/github.com/bblfsh/python-driver/.sdk && \
    chmod a+rx $GOPATH/src/github.com/bblfsh/python-driver/.sdk/etc/run.sh && \

    chown -R 1000 $GOPATH/src/github.com/bblfsh/java-driver && \
    chown -R 1000 $GOPATH/src/github.com/bblfsh/java-driver/.sdk && \
    chmod a+rx $GOPATH/src/github.com/bblfsh/java-driver/.sdk/etc/run.sh

# The drivers "make build" doesnt work as root thus the prebblfsh user
# that will be needed in the run script to do the drivers "make build"
RUN useradd prebblfsh -u 1000 && \
    chgrp -R docker /root && \
    chmod -R g+rwx /root && \
    gpasswd -a prebblfsh docker
