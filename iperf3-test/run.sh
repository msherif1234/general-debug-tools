#!/usr/bin/env bash
set -eu

CLIENTS=$(oc get pods -l app=iperf3-client -o name | cut -d'/' -f2)

for POD in ${CLIENTS}; do
    until $(oc get pod ${POD} -o jsonpath='{.status.containerStatuses[0].ready}'); do
        echo "Waiting for ${POD} to start..."
        sleep 5
    done
    HOST=$(oc get pod ${POD} -o jsonpath='{.status.hostIP}')
    #oc exec -it ${POD} -- bash -c "iperf3 -c ${IPERF3_SERVER_SERVICE_HOST} -p ${IPERF3_SERVER_SERVICE_PORT} -t 1"
    oc exec -it ${POD} -- iperf3 -c iperf3-server -T  "Client on ${HOST}" $@

    echo
done
