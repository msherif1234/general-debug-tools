#!/usr/bin/env bash
#
#set -x
function log {
    echo "$(TZ=Z date +%FT%TZ) $0: $*"
}

function yell {
    echo "$(TZ=Z date +%FT%TZ) $0: $*" >&2
}

# get lb svc ip
function get_lb_svc_ip {
    svc_lb_ip=$(kubectl get svc $1 --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
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

# check_ovs_flows
function check_ovs_flows {
    for f in $(oc -n openshift-ovn-kubernetes get pods -l app=ovnkube-node \
        -o jsonpath="{.items[*].metadata.name}")
    do
    ovs_flows=$(oc exec -n openshift-ovn-kubernetes "${f}" -c ovnkube-node -- ovs-ofctl dump-flows br-ex | grep $1)
    done
}

function check_ip_tables {
 for f in $(oc -n openshift-ovn-kubernetes get pods -l app=ovnkube-node \
        -o jsonpath="{.items[*].metadata.name}")
    do
    iptable_rules=$(oc exec -n openshift-ovn-kubernetes "${f}" -c ovnkube-node -- iptables -L OVN-KUBE-NODEPORT -t nat -n -v)
    done

}

get_lb_svc_ip $1
log LoadBalancer Service IP: $svc_lb_ip

if check_ovnkube_nodes
then
    log Shared Gateway mode
    check_ovs_flows $svc_lb_ip 
# Check conntrack
# drop in the work node bash
# ovs-appctl dpctl/dump-conntrack | grep <svc local port>
    log OVS flows For LB SVC: $ovs_flows
else
    log Local Gateway mode
    check_ip_tables
    log IP tables For LB SVC: $iptable_rules
fi

