#!/bin/bash

# Example:
# docker run -v $(pwd):/script --privileged -it --rm bblfshdev bash /script/test_server_issue34.sh

GOPATH="/root/go"
PATH="$GOPATH/bin:/usr/local/go/bin:$PATH"
HOME="/root"

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
$GOPATH/bin/bblfsh-sdk prepare-build                              && \
$GOPATH/bin/bblfsh-sdk update                                     && \
chgrp -R docker $GOPATH/src/github.com/bblfsh/python-driver       && \
chmod g+rwx -R $GOPATH/src/github.com/bblfsh/python-driver        && \
export BUILD_UID=1000                                             && \
make build                                                        && \
docker tag `docker images --quiet|head -1` bblfsh/python-driver:latest && \

## Real testing starts here ~~~~~~~~~~~~

echo "Build and run the server..."
cd $GOPATH/src/github.com/bblfsh/server/cmd/bblfsh && \
./bblfsh server --transport=docker-daemon > /root/server_out.log 2> /root/server_err.log &    
sleep 2 && \

echo "Cloning and installing specific client-python branch..."
cd /root                                                          && \
git clone https://github.com/vmarkovtsev/bblfsh.client-python.git && \
cd /root/bblfsh.client-python                                     && \
git checkout remotes/origin/main-change                           && \
pip3 install .                                                    && \

python3 -m bblfsh --disable-bblfsh-autorun /scripts/boom.py
echo $?

echo "Testing for 500 iterations with a sleep of 5 seconds"
for i in `seq 1 1000`;
do
    python3 -m bblfsh --disable-bblfsh-autorun bblfsh/github/com/bblfsh/sdk/__init__.py bblfsh/github/com/bblfsh/sdk/protocol/__init__.py  bblfsh/github/com/bblfsh/sdk/protocol/generated_pb2.py  bblfsh/github/com/bblfsh/sdk/protocol/generated_pb2_grpc.py  bblfsh/github/com/bblfsh/sdk/uast/__init__.py  bblfsh/github/com/bblfsh/sdk/uast/generated_pb2.py > /dev/null 
    echo $?
    python3 -m bblfsh --disable-bblfsh-autorun bblfsh/github/com/bblfsh/sdk/__init__.py bblfsh/github/com/bblfsh/sdk/protocol/__init__.py  bblfsh/github/com/bblfsh/sdk/protocol/generated_pb2.py  bblfsh/github/com/bblfsh/sdk/protocol/generated_pb2_grpc.py  bblfsh/github/com/bblfsh/sdk/uast/__init__.py  bblfsh/github/com/bblfsh/sdk/uast/generated_pb2.py > /dev/null 
    echo $?
    python3 -m bblfsh --disable-bblfsh-autorun bblfsh/github/com/bblfsh/sdk/__init__.py bblfsh/github/com/bblfsh/sdk/protocol/__init__.py  bblfsh/github/com/bblfsh/sdk/protocol/generated_pb2.py  bblfsh/github/com/bblfsh/sdk/protocol/generated_pb2_grpc.py  bblfsh/github/com/bblfsh/sdk/uast/__init__.py  bblfsh/github/com/bblfsh/sdk/uast/generated_pb2.py > /dev/null 
    echo $?
    echo "Finished iteration $i"
done
