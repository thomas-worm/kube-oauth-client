#!/bin/bash

script_dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workspace_dirname="$( cd "${script_dirname}/../.." &> /dev/null && pwd )"
gitpodlocalbin="${workspace_dirname}/.gitpod/usr/local/bin"
kubectlbinpath="${gitpodlocalbin}/kubectl"
sudo ln -f -s $kubectlbinpath /usr/local/bin/kubectl
sudo ln -f -s kubectl /usr/local/bin/k

if test -f "${kubectlbinpath}"; then
    exit 0
fi

mkdir -p $gitpodlocalbin
curl -o kubectlbinpath -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectlbinpath
