#!/bin/bash

script_dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workspace_dirname="$( cd "${script_dirname}/.." &> /dev/null && pwd )"
rootfsdir="${workspace_dirname}/.k3s/rootfs"
rootfslock="${rootfsdir}/rootfs-ready.lock"
k3sreadylock="${rootfsdir}/k3s-ready.lock"

$workspace_dirname/.gitpod/setup/symlinks.sh
$workspace_dirname/.gitpod/setup/qemu.sh
$workspace_dirname/.gitpod/setup/rootfs.sh
$workspace_dirname/.gitpod/setup/kubectl.sh
$workspace_dirname/.gitpod/setup/k3s.sh
