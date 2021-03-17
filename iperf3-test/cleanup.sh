#!/usr/bin/env bash
set -eu

oc delete --cascade -f iperf3.yaml
