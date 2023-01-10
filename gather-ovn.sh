#!/bin/bash

exec 33> $1/gather-spk-ovn.trace
BASH_XTRACEFD=33

date

set -x
#cmd="oc"
cmd="omg"

# identify ovnkube-master leader pod
function get_leader_pod {
    for f in $(${cmd} -n openshift-ovn-kubernetes get pods -l app=ovnkube-master \
        -o jsonpath="{.items[*].metadata.name}")
    do
        f_role=$(${cmd} -n openshift-ovn-kubernetes exec "${f}" -c northd -- \
            ovs-appctl -t /var/run/ovn/ovnnb_db.ctl cluster/status OVN_Northbound | \
            grep -E "^Role: ")
        echo "${f_role}" | grep -q leader && { echo ${f}; return $(/bin/true); }
    done
    return $(/bin/false)
}

#OVNMASTER=$(${cmd} -n openshift-ovn-kubernetes get pods -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep ovnkube-master | head -1)
OVNMASTER=$(get_leader_pod)

echo ">>> Elected master ${OVNMASTER}"
for ns in spk-dns46 spk-data; do

	if ${cmd} api-resources | egrep -q 'ingressroutevlans .*k8s.f5net.com' ; then

		# SPK v1.2

		IPS=$(${cmd} get ingressroutevlans -n $ns -o go-template='{{- range .items -}} {{- if eq .kind "IngressRouteVlan" -}} {{- if eq .spec.internal true -}} {{.spec.selfip_v4s}} {{- "\n"}} {{- end -}} {{- end -}} {{- end -}}' | sed -e 's/\[\(.*\)\]/\1/')

	else

		# SPK v1.3 or higher

		IPS=$({cmd} get f5-spk-vlan -n $ns -o go-template='{{- range .items -}} {{- if eq .kind "F5SPKVlan" -}} {{- if eq .spec.internal true -}} {{.spec.selfip_v4s}} {{- "\n"}} {{- end -}} {{- end -}} {{- end -}}' | sed -e 's/\[\(.*\)\]/\1/')
	fi

	echo ">>> Gathering OVN routes for SPK internal IPs in namespace $ns"

	for ip in $IPS ; do

		echo "> SPK IP $ip"

		${cmd} -n openshift-ovn-kubernetes exec -it $OVNMASTER -- ovn-nbctl --no-leader-only find Logical_Router_Static_Route nexthop=$ip
	done

done


echo ">>> Gathering ovn-nbctl show"
${cmd} -n openshift-ovn-kubernetes exec -it $OVNMASTER -- ovn-nbctl --no-leader-only show

echo ">>> Gathering router list"
${cmd} -n openshift-ovn-kubernetes exec -it $OVNMASTER -- ovn-nbctl --no-leader-only lr-list

echo ">>> Gathering router static routes"
${cmd} -n openshift-ovn-kubernetes exec -it $OVNMASTER -- ovn-nbctl --no-leader-only find logical_router_static_route

ROUTERS=$(${cmd} -n openshift-ovn-kubernetes exec -it $OVNMASTER -- ovn-nbctl --no-leader-only lr-list | cut -d " " -f 1)

echo ">>> Gathering all routes"
for router in $ROUTERS; do 

   echo "> Routes of router $router"
   ${cmd} -n openshift-ovn-kubernetes exec -it $OVNMASTER -- ovn-nbctl --no-leader-only lr-route-list $router

done

echo ">>> Gathering load_balancer_group"
${cmd} -n openshift-ovn-kubernetes exec -it $OVNMASTER -- ovn-nbctl --no-leader-only list load_balancer_group

echo ">>> Gathering ls-lb-list"
for node in $(kubectl get nodes -o json| jq -r '.items[].metadata.name'); do 

	echo "> Node $node"
	${cmd} -n openshift-ovn-kubernetes exec -it $OVNMASTER -c sbdb -- /bin/sh -c "ovn-nbctl --no-leader-only ls-lb-list $node"
done

echo ">>> Gathering acl-list"
for node in $(kubectl get nodes -o json| jq -r '.items[].metadata.name'); do 

	echo "> Node $node"
	${cmd} -n openshift-ovn-kubernetes exec -it $OVNMASTER -c sbdb -- /bin/sh -c "ovn-nbctl --no-leader-only acl-list $node"
done

echo ">>> Gathering lr-policy-list and lr-nat-list"
for router in $ROUTERS; do 

   echo "> Routes of router $router"
   ${cmd} -n openshift-ovn-kubernetes exec -it $OVNMASTER  -- /bin/sh -c "ovn-nbctl --no-leader-only lr-policy-list $router"
   ${cmd} -n openshift-ovn-kubernetes exec -it $OVNMASTER  -- /bin/sh -c "ovn-nbctl --no-leader-only lr-nat-list $router"
done

echo ">>> Gathering OVS interfaces"
for pod in $(kubectl get pods -n openshift-ovn-kubernetes -l app=ovnkube-node -o json| jq -r '.items[].metadata.name'); do
   ${cmd} -n openshift-ovn-kubernetes exec -it $pod  -- /bin/sh -c "ovs-vsctl show"
   ${cmd} -n openshift-ovn-kubernetes exec -it $pod  -- /bin/sh -c "ovs-ofctl dump-ports-desc br-int"
   ${cmd} -n openshift-ovn-kubernetes exec -it $pod  -- /bin/sh -c "ovs-ofctl dump-ports-desc br-ex"
done

echo ">>> Gathering OVN masters logs"
for pod in $(kubectl get pods -n openshift-ovn-kubernetes -l app=ovnkube-master -o json| jq -r '.items[].metadata.name'); do 

  for c in northd nbdb kube-rbac-proxy sbdb ovnkube-master ovn-dbchecker ; do 

    echo "> Log for POD $pod CONTAINER $c"
    ${cmd} -n openshift-ovn-kubernetes logs $pod -c $c 

  done
done

echo ">>> Gathering OVN nodes logs"
for pod in $(kubectl get pods -n openshift-ovn-kubernetes -l app=ovnkube-node -o json| jq -r '.items[].metadata.name'); do

  for c in ovn-controller kube-rbac-proxy ovnkube-node ; do

    echo "> Log for POD $pod CONTAINER $c"
    ${cmd} -n openshift-ovn-kubernetes logs $pod -c $c

  done
done

