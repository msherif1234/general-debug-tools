ARG PWRU_VERSION="1.0.4"
ARG BPFTRACE_VERSION="cf54d1682c19c0b2ebc7f81160282345c0aded79-alpine"
ARG RETIS_VERSION="latest"
ARG BPFMAN_VERSION="latest"

FROM docker.io/cilium/pwru:${PWRU_VERSION} AS pwru
FROM quay.io/iovisor/bpftrace:${BPFTRACE_VERSION} AS bpftrace
FROM quay.io/retis/retis:${RETIS_VERSION} AS retis
FROM quay.io/bpfman/bpfman:${BPFMAN_VERSION} AS bpfman

FROM docker.io/library/golang:1.20 as builder
RUN git clone https://github.com/redcanaryco/ebpfmon.git && cd ebpfmon && make && cp ./ebpfmon /usr/bin/ebpfmon
RUN curl -fLJ https://github.com/Netflix/bpftop/releases/download/v0.5.2/bpftop-x86_64-unknown-linux-gnu -o bpftop && chmod +x bpftop && cp bpftop /usr/bin/bpftop
#RUN git clone https://github.com/chaudron/ovs.git -b dev/kernel_delay && cp ./ovs/utilities/usdt-scripts/kernel_delay.py /usr/bin/kernel_delay.py && chmod +x /usr/bin/kernel_delay.py

FROM docker.io/fedora:40

RUN yum -y install \
    iproute \
    tcpdump \
    wireshark-cli \
    vim-enhanced \
    git \
    gdb \
    curl \
    grpcurl \
    findutils \
    procps-ng \
    nftables \
    bcc \
    bpftool \
    strace \
    ltrace \
    trace-cmd \
    perf \
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

#RUN wget http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch3.1/3.1.0/61.el8fdp/x86_64/openvswitch3.1-debuginfo-3.1.0-61.el8fdp.x86_64.rpm
#RUN wget http://download-node-02.eng.bos.redhat.com/brewroot/packages/openvswitch3.1/3.1.0/61.el8fdp/x86_64/openvswitch3.1-debugsource-3.1.0-61.el8fdp.x86_64.rpm
#RUN wget https://mirrors.edge.kernel.org/pub/linux/kernel/tools/perf/v6.3.0/perf-6.3.0.tar.xz && tar xf perf-6.3.0.tar.xz && cd perf-6.3.0/ && make -C tools/perf install && cd ../ && rm -rf perf-6.3.0*

#RUN rpm -i \
#    openvswitch3.1-debuginfo-3.1.0-61.el8fdp.x86_64.rpm \
#    openvswitch3.1-debugsource-3.1.0-61.el8fdp.x86_64.rpm

COPY --from=pwru /usr/local/bin/pwru /usr/local/bin/pwru
COPY --from=bpftrace /usr/bin/bpftrace /usr/local/bin/bpftrace
COPY --from=retis /usr/bin/retis /usr/local/bin/retis
COPY --from=builder /usr/bin/ebpfmon /usr/local/bin/ebpfmon
COPY --from=builder /usr/bin/bpftop /usr/local/bin/bpftop
COPY --from=bpfman /bpfman /usr/local/bin/bpfman
#COPY --from=builder /usr/bin/kernel_delay.py /usr/local/bin/kernel_delay.py
