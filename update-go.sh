#!/bin/bash
GOBIN=`which go`
sudo rm -rf $GOBIN
mkdir -p $HOME/go/src	
git clone https://github.com/udhos/update-golang.git
	
pushd update-golang
sudo RELEASE=1.20.10 ./update-golang.sh # if need to install latest remove RELEASE=xxx
popd
	
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/bin
rm -rf ./update-golang

