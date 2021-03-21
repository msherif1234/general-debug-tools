#!/bin/bash

# script to setup Fedora VM to use it :-
# sudo usermod -aG wheel $USERNAME
# ./setup_vm.sh -g <github id>
# Note if we don't specify github id will clone master repo instead of your own fork for ovn-kubenetes repo.

set +x

function setup_fedora_vm() {
	#change to use cgroupsv1 instead of cgroupsv2
	sudo sed -i 's/GRUB_CMDLINE_LINUX="[^"]*/& systemd.unified_cgroup_hierarchy=0/' /etc/default/grub
	sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg

	#install Go v1.16
	mkdir -p $HOME/go/src
	git clone https://github.com/udhos/update-golang.git
	pushd update-golang
	./update-golang.sh
	popd

	export GOPATH=$HOME/go
	export PATH=$PATH:$GOPATH/bin
	export PATH=$PATH:/usr/local/go/bin
	export PATH=$PATH:$HOME/bin

	rm -rf ./update-golang

	#install docker
	sudo dnf install -y moby-engine docker-compose
	sudo systemctl enable docker
	sudo systemctl start docker
	sudo groupadd docker
	sudo usermod -aG docker $USERNAME

	#Install virtualization tools
	sudo dnf groupinfo virtualization
	sudo dnf group install -y --with-optional virtualization
	sudo systemctl start libvirtd
	sudo systemctl enable libvirtd

	#Install kind
	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64
	chmod +x ./kind
	sudo mv ./kind /usr/local/bin

	#Install kubectl
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

	#Install j2
	sudo dnf install -y snapd
	sudo ln -s /var/lib/snapd/snap /snap
	sudo snap install -y j2

	#Install make
	sudo dnf install -y make

	#Install tmate
	sudo dnf install -y tmate

	#Change firewall to use iptables
	sudo sed -i "s/^FirewallBackend\=.*/FirewallBackend=iptables/" "/etc/firewalld/firewalld.conf"
	sudo systemctl restart firewalld

	#Install xterm
	sudo dnf install -y xterm

	#Instal gvim
	sudo dnf install -y vim-X11

	#install Goland
	sudo snap install goland --classic
	
	#install Lens
	sudo snap install kontena-lens --classic
	
	# install oc CLI tool
	# https://access.redhat.com/downloads/content/290/ver=4.7/rhel---8/4.7.1/x86_64/product-software
	# need latest version to be able to rin oc adm must-gather

	#install wireshark
	sudo dnf install -y wireshark
	sudo usermod -a -G wireshark $USERNAME

	#install awscli
	sudo dnf install -y awscli

	# clone upstream repo
	cd $GOPATH/src
	if [[ -z "$mygitid" ]]; then
	    git clone https://github.com/ovn-kubernetes.git
	else 		
	    git clone https://github.com/$mygitid/ovn-kubernetes.git
	fi

	#clone k8s
	cd $GOPATH/src
	mkdir k8s.io; cd k8s.io
	git clone https://github.com/kubernetes/kubernetes.git
	#build e2e test binary
	pushd $GOPATH/src/k8s.io/kubernetes
	make WHAT="test/e2e/e2e.test vendor/github.com/onsi/ginkgo/ginkgo"
	popd

	#Reboot
	sudo reboot
}

while getopts g: flag
do
    case "${flag}" in
        g) mygitid=${OPTARG};;
        *) echo "Invalid arg";;
    esac
done

echo "Git userID: $mygitid";

setup_fedora_vm
