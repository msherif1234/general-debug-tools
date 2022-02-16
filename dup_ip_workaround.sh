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

# return whether multiple pods have the same ip
function duplicate_ip_exists {
    leader_pod=$1
    # from OVN nd db, get the addresses from all the logical ports.
    # then, filter on all the addresses that start with 2 characters and a collon (e.g. 06:ca:af:c7:2e:b5 mac)
    # then, sort the addresses and count for uniqueness
    # then, filter out the lines that has '1' as the value, taking into account the initial spaces
    dups_check=$(oc -n openshift-ovn-kubernetes exec "${leader_pod}" -c northd -- \
        ovn-nbctl --bare --columns addresses list logical_switch_port | grep -E "^..:" | \
        sort | uniq -c | grep -v -E "^[[:space:]]*1[[:space:]]")

    [ -n "${dups_check}" ] && {
        yell duplicate ips found ${dups_check}
        return $(/bin/true)
    }

    return $(/bin/false)
}

# restart master ovn-k8 pods
function restart_master_ovn_k8s {
    for master_node in $(oc get nodes --selector="node-role.kubernetes.io/master"="" \
        -o jsonpath='{range .items[*].metadata}{.name}{"\n"}{end}')
    do
        yell restart ovnkube-master in node ${master_node}
        oc delete pod --field-selector spec.nodeName=${master_node} -n openshift-ovn-kubernetes \
        --selector=app=ovnkube-master
    done
}

leader_pod=$(get_leader_pod)
[ -n "${leader_pod}" ] || {
    yell cannot find ovnk-master leader
    exit 1
}
log leader pod is ${leader_pod}
if duplicate_ip_exists ${leader_pod}
then
    yell duplicate found. restarting ovnk8 pods to make syncpods delete the stale ports
    restart_master_ovn_k8s
else
    log no duplicate ips detected in ovn nd db
fi


