ARG PWRU_VERSION="0.0.8"
ARG BPFTRACE_VERSION="cf54d1682c19c0b2ebc7f81160282345c0aded79-alpine"
ARG RETIS_VERSION="1.1.0"

FROM docker.io/cilium/pwru:${PWRU_VERSION} AS pwru
FROM quay.io/iovisor/bpftrace:${BPFTRACE_VERSION} AS bpftrace
FROM quay.io/retis/retis:${RETIS_VERSION} AS retis

FROM docker.io/library/golang:1.20 as builder
RUN git clone https://github.com/redcanaryco/ebpfmon.git && cd ebpfmon && make && cp ./ebpfmon /usr/bin/ebpfmon

FROM docker.io/fedora:37

RUN yum -y install \
    iproute \
    tcpdump \
    wireshark-cli \
    vim-enhanced \
    git \
    gdb \
    curl \
    findutils \
    procps-ng \
    nftables \
    bcc \
    bpftool \
    strace \
    ltrace \
    trace-cmd \
    xz \
    xdp-tools \
    nmap-ncat \
    bc \
    iputils \
    net-tools \
    conntrack-tools \
    bind-utils \
    openvswitch \
    openvswitch-test \
    python3-openvswitch \
    ovn \
    iptables-nft \
    iptables-legacy \
    arptables-legacy \
    ebtables-legacy \
    iptables-utils \
	iproute-tc \
    kernel-headers \
    glibc-headers \
    @development-tools \
    darkhttpd \
    bcc-tools perl-interpreter \
    python3-pytz  python3-psutil

RUN wget https://github.com/chaudron/ovs/blob/dev/kernel_delay/utilities/usdt-scripts/kernel_delay.py && chmod +x kernel_delay.py
RUN wget https://mirrors.edge.kernel.org/pub/linux/kernel/tools/perf/v6.3.0/perf-6.3.0.tar.xz && tar xf perf-6.3.0.tar.xz && cd perf-6.3.0/ && make -C tools/perf install && cd ../ && rm -rf perf-6.3.0*

COPY --from=pwru /usr/local/bin/pwru /usr/local/bin/pwru
COPY --from=bpftrace /usr/bin/bpftrace /usr/local/bin/bpftrace
COPY --from=retis /usr/bin/retis /usr/local/bin/retis
COPY --from=builder /usr/bin/ebpfmon /usr/local/bin/ebpfmon
