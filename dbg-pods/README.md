# To build netutils docker images

```bash
docker build -f Dockerfile -t netutils
docker tag localhost/netutils:latest quay.io/mmahmoud/netutils:latest
docker push quay.io/mmahmoud/netutils:latest
```

# To deploy pwru pod on an existing OCP cluster
- make sure to change `kubernetes.io/hostname:` to match the nodeName you wanted to deploy this pod on.
- oc create -f ~/ovn-tools/dbg-pods/pwru.yaml
- example running pwru commands
```bash
 oc exec -it pwru-deployment-76cb578546-wz4wc -- pwru --all-kmods --filter-proto tcp --filter-port 33637 --output-tuple
2023/01/11 15:42:04 Per cpu buffer size: 4096 bytes
2023/01/11 15:42:04 Attaching kprobes...
```
- example running conntrack
```bash
oc exec -it pwru-deployment-686d6ffb5f-wvg8g -- conntrack -L | grep 66734
```
- example running bpftool
```bash
oc exec -it pwru-deployment-686d6ffb5f-wvg8g -- bpftool --help
Usage: bpftool [OPTIONS] OBJECT { COMMAND | help }
       bpftool batch file FILE
       bpftool version

       OBJECT := { prog | map | link | cgroup | perf | net | feature | btf | gen | struct_ops | iter }
       OPTIONS := { {-j|--json} [{-p|--pretty}] | {-d|--debug} | {-l|--legacy} |
                    {-V|--version} }
```

