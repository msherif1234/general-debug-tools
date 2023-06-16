ARG PWRU_VERSION="0.0.8"
ARG BPFTRACE_VERSION="cf54d1682c19c0b2ebc7f81160282345c0aded79-alpine"
ARG RETIS_VERSION="1.0.0"

FROM docker.io/cilium/pwru:${PWRU_VERSION} AS pwru
FROM quay.io/iovisor/bpftrace:${BPFTRACE_VERSION} AS bpftrace
FROM quay.io/retis/retis:${RETIS_VERSION} AS retis

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
    perf \
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
    kernel-headers \
    glibc-headers \
    @development-tools \
    darkhttpd

COPY --from=pwru /usr/local/bin/pwru /usr/local/bin/pwru
COPY --from=bpftrace /usr/bin/bpftrace /usr/local/bin/bpftrace
COPY --from=retis /usr/bin/retis /usr/local/bin/retis
