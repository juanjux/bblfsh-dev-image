#!/bin/bash

# Example:
# docker run -v $(pwd):/script --privileged -it --rm bblfshdev bash /script/run.sh

export GOPATH="/root/go"
export PATH="$GOPATH/bin:/usr/local/go/bin:$PATH"

# Docker run part starts here (no way to run privileged commands inside docker build)
service docker start && \
service docker status 

if [ $? != 0 ]
then
    echo "Docker service not started. Did you started docker run with --privileged?"
    exit 1
fi

# This also can't be done in the Dockerfile (same: no privileged operations on build) 
echo "Building Python driver image..."
cd $GOPATH/src/github.com/bblfsh/python-driver                    && \
bblfsh-sdk prepare-build                                          && \
bblfsh-sdk update                                                 && \
su - prebblfsh -c "export GOPATH=/root/go && cd $GOPATH/src/github.com/bblfsh/python-driver && make build" && \
docker tag `docker images --quiet|head -1` bblfsh/python-driver:latest && \

echo "Build and run the server..."
cd $GOPATH/src/github.com/bblfsh/server/cmd/bblfsh && \
./bblfsh server --transport=docker-daemon&    
sleep 2                                            && \

echo "Cloning and installing specific client-python branch..."
cd /root                                                          && \
git clone https://github.com/vmarkovtsev/bblfsh.client-python.git && \
cd /root/bblfsh.client-python                                     && \
git checkout remotes/origin/main-change                           && \
pip3 install -U .                                                 && \

echo "Finished downloading and building ~master bblfsh components, docker images and dependencies"
echo "Break all the things!"
bash
