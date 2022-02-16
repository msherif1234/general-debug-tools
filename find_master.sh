#!/usr/bin/env bash
#

function log {
    echo "$(TZ=Z date +%FT%TZ) $0: $*"
}

function yell {
    echo "$(TZ=Z date +%FT%TZ) $0: $*" >&2
}

# identify ovnkube-master leader pod
function get_leader_pod {
    for f in $(oc -n openshift-ovn-kubernetes get pods -l app=ovnkube-master \
        -o jsonpath="{.items[*].metadata.name}")
    do
        f_role=$(oc -n openshift-ovn-kubernetes exec "${f}" -c northd -- \
            ovs-appctl -t /var/run/ovn/ovnnb_db.ctl cluster/status OVN_Northbound | \
            grep -E "^Role: ")
        echo "${f_role}" | grep -q leader && { echo ${f}; return $(/bin/true); }
    done
    return $(/bin/false)
}


leader_pod=$(get_leader_pod)
[ -n "${leader_pod}" ] || {
    yell cannot find ovnk-master leader
    exit 1
}
log leader pod is ${leader_pod}


