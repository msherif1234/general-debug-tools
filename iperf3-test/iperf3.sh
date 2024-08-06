#!/usr/bin/env bash
set +x

NAMESPACE=iperf

cd $(dirname $0)
function setup() {
        oc create ns ${NAMESPACE}
	oc create -f iperf3.yaml

	until $(oc get pods -n ${NAMESPACE} -l app=iperf3-server -o jsonpath='{.items[0].status.containerStatuses[0].ready}'); do
    	echo "Waiting for iperf3 server to start..."
    	sleep 5
	done

	echo "Server is running"
}

function run() {
	CLIENTS=$(oc get pods -n ${NAMESPACE} -l app=iperf3-client -o name | cut -d'/' -f2)

	for POD in ${CLIENTS}; do
	counter=0
    	until [[ $(oc get pod ${POD} -n ${NAMESPACE} -o jsonpath='{.status.containerStatuses[0].ready}') && $counter -lt 5 ]]; do
        	echo "Waiting for ${POD} to start..."
        	sleep 5
		counter=$((counter+1))
    	done

	if [[ $counter -lt 5 ]]; then
            cnt=1
            while [ $cnt -le 10 ]; do
    	    	oc exec -it ${POD} -n ${NAMESPACE} -- bash -c 'iperf3 -c "$IPERF3_SERVER_SERVICE_HOST" -p "$IPERF3_SERVER_SERVICE_PORT_TCP" -t10 --connect-timeout 1'
    	    	#oc exec -it ${POD} -n ${NAMESPACE} -- bash -c 'iperf3 -u -c "$IPERF3_SERVER_SERVICE_HOST" -p "$IPERF3_SERVER_SERVICE_PORT_UDP" -t5'
            	sleep 1
            	((cnt++))
            done
	fi

    	echo
	done
}

function cleanup() {
	oc delete --cascade -f iperf3.yaml
	#oc delete namespace ${NAMESPACE}
}

setup
run
cleanup

