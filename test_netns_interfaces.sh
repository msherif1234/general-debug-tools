#!/usr/bin/bash
set -x

ITERATIONS=10

function create_ns_interfaces() {
    cnt=1
    while [ $cnt -le ${ITERATIONS} ]; do
        ip netns add n${cnt}
        ip link add dev br${cnt} type bridge
        ip link set br${cnt} up
        ip netns exec n${cnt} ip link add name vethin${cnt} type veth peer name vethout${cnt}
        ip netns exec n${cnt} ip link set vethout${cnt} netns ${cnt}

        ip link set dev vethout${cnt} master br${cnt}
        ip link set vethout${cnt} up
        ip netns exec n${cnt} ip link set vethin${cnt} up
        sleep 1
        ((cnt++))
    done
}

function delete_ns_interfaces() {
    cnt=1
    while [ $cnt -le ${ITERATIONS} ]; do
        ip netns delete n${cnt}
        ip link del dev br${cnt}
        ip link del vethin${cnt}
        ip link del vethout${cnt}
        sleep 1
        ((cnt++))
    done
}

create_ns_interfaces
sleep 60
delete_ns_interfaces
