# To build netutils docker images

```bash
docker build -f Dockerfile . -t netutils
docker tag netutils:latest quay.io/mmahmoud/netutils:latest
docker push quay.io/mmahmoud/netutils:latest
```

# To deploy dbgtools pod on an existing OCP cluster
- make sure to change `kubernetes.io/hostname:` to match the nodeName you wanted to deploy this pod on.
- oc create -f ~/ovn-tools/dbg-pods/dbg_pod.yaml
- example running pwru commands
```bash
 oc exec -it dbgtools-deployment-76cb578546-wz4wc -- pwru --all-kmods --filter-proto tcp --filter-port 33637 --output-tuple
2023/01/11 15:42:04 Per cpu buffer size: 4096 bytes
2023/01/11 15:42:04 Attaching kprobes...
```
- example running conntrack
```bash
oc exec -it dbgtools-deployment-686d6ffb5f-wvg8g -- conntrack -L | grep 66734
```
- example running bpftool
```bash
oc exec -it dbgtools-deployment-686d6ffb5f-wvg8g -- bpftool --help
Usage: bpftool [OPTIONS] OBJECT { COMMAND | help }
       bpftool batch file FILE
       bpftool version

       OBJECT := { prog | map | link | cgroup | perf | net | feature | btf | gen | struct_ops | iter }
       OPTIONS := { {-j|--json} [{-p|--pretty}] | {-d|--debug} | {-l|--legacy} |
                    {-V|--version} }
```
- example running retis
```bash
oc exec -it dbgtools-deployment-87f4d9b8f-5zbfq -- retis --help

Trace packets on the Linux kernel

retis is a tool for capturing networking-related events from the system using ebpf and analyzing them.

Usage: retis [OPTIONS] <COMMAND>

Commands:
  print    Print events to stdout
  collect  Collect network events
  sort     Sort events in series based on tracking id
  profile  Manage Profiles
  help     Print this message or the help of the given subcommand(s)

Options:
      --log-level <LOG_LEVEL>
          Log level
          
          [default: info]
          [possible values: error, warn, info, debug]

  -p, --profile <PROFILE>
          Comma separated list of profile names to apply

  -h, --help
          Print help (see a summary with '-h')

  -V, --version
          Print version
```
- to use ebpfmon tool
```bash
oc exec -it dbgtools-deployment-78b76b4f84-bq95d -n default -- bash
$ mkdir -p /tmp/cgroup2
$ mount -t cgroup2 none /tmp/cgroup2
$ ebpfmon
Collecting bpf information. This may take a few seconds

```

- kernel_delay.py
troubleshooting delays and identofy if its kernel or ovs related
for more info refer to https://developers.redhat.com/articles/2023/07/24/troubleshooting-open-vswitch-kernel-blame

for examples refer to https://github.com/chaudron/ovs/blob/dev/kernel_delay/utilities/usdt-scripts/kernel_delay.rst
