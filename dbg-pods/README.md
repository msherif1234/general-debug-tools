# To build netutils docker images

```bash
docker build -f Dockerfile -t netutils
docker tag localhost/netutils:latest quay.io/mmahmoud/netutils:latest
docker push quay.io/mmahmoud/netutils:latest
```

# To deploy pwru pod on existing OCP cluster
- make sure to change `kubernetes.io/hostname:` to match the nodeName you wanted to deploy this pod on
- oc create -f ~/ovn-tools/dbg-pods/pwru.yaml
- drop in container shell and run pwru commands
```bash
 oc exec -it pwru-deployment-76cb578546-wz4wc -- bash
[root@08qx6pk-b5564-cxf9x-master-1 /]# pwru --filter-proto tcp --filter-src-port 33637
2023/01/11 15:42:04 Per cpu buffer size: 4096 bytes
2023/01/11 15:42:04 Attaching kprobes...
```

