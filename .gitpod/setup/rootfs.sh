#!/bin/bash

set -euo pipefail

script_dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workspace_dirname="$( cd "${script_dirname}/../.." &> /dev/null && pwd )"
rootfsdir="${workspace_dirname}/.k3s/rootfs"
rootfslock="${rootfsdir}/rootfs-ready.lock"

if test -f "${rootfslock}"; then
    exit 0
fi

img_url="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.tar.gz"

rm -Rf $rootfsdir
mkdir -p $rootfsdir

pushd $rootfsdir

curl -L $img_url | tar -xzvf -

qemu-img resize --preallocation=off jammy-server-cloudimg-amd64.img +20G

sudo virt-customize -a jammy-server-cloudimg-amd64.img --run-command 'resize2fs /dev/sda'

sudo virt-customize -a jammy-server-cloudimg-amd64.img --root-password password:root

netconf="
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: yes
"

# networking setup
sudo virt-customize -a jammy-server-cloudimg-amd64.img --run-command "echo '${netconf}' > /etc/netplan/01-net.yaml"

# copy kernel modules
for kernel_versions in `find /lib/modules -mindepth 1 -maxdepth 1 -type d`; do
  sudo virt-customize -a jammy-server-cloudimg-amd64.img --copy-in ${kernel_versions}:/lib/modules
done

# ssh
sudo virt-customize -a jammy-server-cloudimg-amd64.img --run-command 'apt remove openssh-server -y && apt install openssh-server -y'
sudo virt-customize -a jammy-server-cloudimg-amd64.img --run-command "sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config"
sudo virt-customize -a jammy-server-cloudimg-amd64.img --run-command "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config"

popd

touch $rootfslock
