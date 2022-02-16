#!/bin/bash

exec 33> $1/gather-spk-ovn.trace
BASH_XTRACEFD=33

date

set -x

OVNMASTER=$(oc -n openshift-ovn-kubernetes get pods -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep ovnkube-master | head -1)

for ns in spk-dns46 spk-data; do

	if oc api-resources | egrep -q 'ingressroutevlans .*k8s.f5net.com' ; then

		# SPK v1.2

		IPS=$(oc get ingressroutevlans -n $ns -o go-template='{{- range .items -}} {{- if eq .kind "IngressRouteVlan" -}} {{- if eq .spec.internal true -}} {{.spec.selfip_v4s}} {{- "\n"}} {{- end -}} {{- end -}} {{- end -}}' | sed -e 's/\[\(.*\)\]/\1/')

	else

		# SPK v1.3 or higher

		IPS=$(oc get f5-spk-vlan -n $ns -o go-template='{{- range .items -}} {{- if eq .kind "F5SPKVlan" -}} {{- if eq .spec.internal true -}} {{.spec.selfip_v4s}} {{- "\n"}} {{- end -}} {{- end -}} {{- end -}}' | sed -e 's/\[\(.*\)\]/\1/')
	fi

	echo ">>> Gathering OVN routes for SPK internal IPs in namespace $ns"

	for ip in $IPS ; do

		echo "> SPK IP $ip"

		oc -n openshift-ovn-kubernetes exec -it $OVNMASTER -- ovn-nbctl --no-leader-only find Logical_Router_Static_Route nexthop=$ip
	done

done


echo ">>> Gathering ovn-nbctl show"
oc -n openshift-ovn-kubernetes exec -it $OVNMASTER -- ovn-nbctl --no-leader-only show

echo ">>> Gathering router list"
oc -n openshift-ovn-kubernetes exec -it $OVNMASTER -- ovn-nbctl --no-leader-only lr-list

ROUTERS=$(oc -n openshift-ovn-kubernetes exec -it $OVNMASTER -- ovn-nbctl --no-leader-only lr-list | cut -d " " -f 1)

echo ">>> Gathering all routes"
for router in $ROUTERS; do 

   echo "> Routes of router $router"
   oc -n openshift-ovn-kubernetes exec -it $OVNMASTER -- ovn-nbctl --no-leader-only lr-route-list $router

done

echo ">>> Gathering ls-lb-list"
for node in $(kubectl get nodes -o json| jq -r '.items[].metadata.name'); do 

	echo "> Node $node"
	oc -n openshift-ovn-kubernetes exec -it $OVNMASTER -c sbdb -- /bin/sh -c "ovn-nbctl --no-leader-only ls-lb-list $node"
done

echo ">>> Gathering OVN masters logs"
for pod in $(kubectl get pods -n openshift-ovn-kubernetes -l app=ovnkube-master -o json| jq -r '.items[].metadata.name'); do 

  for c in northd nbdb kube-rbac-proxy sbdb ovnkube-master ovn-dbchecker ; do 

    echo "> Log for POD $pod CONTAINER $c"
    oc -n openshift-ovn-kubernetes logs $pod -c $c 

  done
done

echo ">>> Gathering OVN nodes logs"
for pod in $(kubectl get pods -n openshift-ovn-kubernetes -l app=ovnkube-node -o json| jq -r '.items[].metadata.name'); do

  for c in ovn-controller kube-rbac-proxy ovnkube-node ; do

    echo "> Log for POD $pod CONTAINER $c"
    oc -n openshift-ovn-kubernetes logs $pod -c $c

  done
done

