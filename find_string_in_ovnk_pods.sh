#!/usr/bin/env bash
#
set -x

function log {
    echo "$(TZ=Z date +%FT%TZ) $0: $*"
}

function yell {
    echo "$(TZ=Z date +%FT%TZ) $0: $*" >&2
}

function master_get_pattern {
    for p in $(oc -n openshift-ovn-kubernetest get pods -l app=ovnkube-master \
        -o jsonpath="{.items[*].metadata.name}")
    do
	pattern=$(oc logs -n openshift-ovn-kubernetes "$p" -c ovnkube-master | grep -E "$1")    
    done
    return $(/bin/false)
}

function worker_get_pattern {
    for p in $(oc -n openshift-ovn-kubernetest get pods -l app=ovnkube-worker \
        -o jsonpath="{.items[*].metadata.name}")
    do
	pattern=$(oc logs -n openshift-ovn-kubernetes "$p" -c ovnkube-node | grep -E "$1")    
    done
    return $(/bin/false)
}

master_get_pattern "$1"
worker_get_pattern "$1"

