#!/usr/bin/env bash
set -eu

cd $(dirname $0)

./setup.sh
./run.sh $@
./cleanup.sh
