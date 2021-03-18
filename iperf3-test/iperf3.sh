#!/usr/bin/env bash
set -eu

cd $(dirname $0)

function setup() {
	oc create -f iperf3.yaml

	until $(oc get pods -l app=iperf3-server -o jsonpath='{.items[0].status.containerStatuses[0].ready}'); do
    	echo "Waiting for iperf3 server to start..."
    	sleep 5
	done

	echo "Server is running"
}

function run() {
	CLIENTS=$(oc get pods -l app=iperf3-client -o name | cut -d'/' -f2)

	for POD in ${CLIENTS}; do
    	until $(oc get pod ${POD} -o jsonpath='{.status.containerStatuses[0].ready}'); do
        	echo "Waiting for ${POD} to start..."
        	sleep 5
    	done
    	#HOST=$(oc get pod ${POD} -o jsonpath='{.status.hostIP}')
    	#oc exec -it ${POD} -- iperf3 -c iperf3-server -T  "Client on ${HOST}" $@
    	oc exec -it ${POD} -- bash -c "iperf3 -c $IPERF3_SERVER_SERVICE_HOST -p $IPERF3_SERVER_SERVICE_PORT"

    	echo
	done
}

function cleanup() {
	oc delete --cascade -f iperf3.yaml
}

setup
run $@
cleanup

