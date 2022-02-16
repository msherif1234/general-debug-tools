#!/usr/bin/env bash
#
#set -x
function log {
    echo "$(TZ=Z date +%FT%TZ) $0: $*"
}

function yell {
    echo "$(TZ=Z date +%FT%TZ) $0: $*" >&2
}

# check ovnkube-nodes
function check_ovnkube_nodes {
    for f in $(oc -n openshift-ovn-kubernetes get pods -l app=ovnkube-node \
        -o jsonpath="{.items[*].metadata.name}")
    do
        gw_mode=$(oc logs -n openshift-ovn-kubernetes "${f}" -c ovnkube-node | \
            grep -E "Gateway:{Mode:")
        echo "${gw_mode}" | grep -q shared && { echo ${f}; return $(/bin/true); }
    done
    return $(/bin/false)
}

if check_ovnkube_nodes
then
    log Shared Gateway mode
else
    log Local Gateway mode
fi


