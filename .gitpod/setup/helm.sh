#!/bin/bash

script_dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workspace_dirname="$( cd "${script_dirname}/../.." &> /dev/null && pwd )"
gitpodlocalbin="${workspace_dirname}/.gitpod/usr/local/bin"
helmbinpath="${gitpodlocalbin}/helm"
sudo ln -f -s $helmbinpath /usr/local/bin/helm

if test -f "${helmbinpath}"; then
    exit 0
fi

sudo rm -f /usr/local/bin/helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sudo bash
mkdir -p $gitpodlocalbin
cp -pv /usr/local/bin/helm $helmbinpath
sudo rm -f /usr/local/bin/helm
sudo ln -f -s $helmbinpath /usr/local/bin/helm
