# kubernetes-iperf3
Simple wrapper around iperf3 to measure network bandwidth from all nodes of a Kubernetes cluster.

## How to use
*Make sure you are using the correct cluster context before running this script: `oc config current-context`*
```
$ ./iperf3.sh
```

### NetworkPolicies
If you need NetworkPolicies you can install it:

```
$ oc apply -f network-policy.yaml
```

And cleanup afterwards:
```
$ oc delete -f network-policy.yaml
```

