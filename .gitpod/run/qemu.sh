#!/bin/bash

set -xeuo pipefail

script_dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workspace_dirname="$( cd "${script_dirname}/../.." &> /dev/null && pwd )"
rootfsdir="${workspace_dirname}/.k3s/rootfs"
rootfslock="${rootfsdir}/rootfs-ready.lock"

function waitrootfs() {
  while ! test -f "${rootfslock}"; do
    sleep 0.1
  done
}

function waitqemu() {
  while ! test -f "/usr/bin/qemu-system-x86_64"; do
    sleep 0.1
  done
  while ! test -f "/boot/vmlinuz"; do
    sleep 0.1
  done
  i=0
  tput sc
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
    case $(($i % 4)) in
      0 ) j="-" ;;
      1 ) j="\\" ;;
      2 ) j="|" ;;
      3 ) j="/" ;;
    esac
    tput rc
    sleep 0.5
    ((i=i+1))
  done
}

waitrootfs
waitqemu

sudo qemu-system-x86_64 -kernel "/boot/vmlinuz" \
-boot c -m 2049M -hda "${rootfsdir}/jammy-server-cloudimg-amd64.img" \
-net user \
-smp 8 \
-append "root=/dev/sda rw console=ttyS0,115200 acpi=off nokaslr" \
-nic user,hostfwd=tcp::2222-:22,hostfwd=tcp::6443-:6443,hostfwd=tcp::32080-:32080 \
-serial mon:stdio -display none
