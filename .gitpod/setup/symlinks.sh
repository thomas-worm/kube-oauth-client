#!/bin/bash

script_dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workspace_dirname="$( cd "$( dirname "${script_dirname}" )/../.." &> /dev/null && pwd )"

mkdir -p ${workspace_dirname}/.k3s
ln -f -s ${workspace_dirname}/.k3s ~/.k3s
mkdir -p ${workspace_dirname}/.kube
ln -f -s ${workspace_dirname}/.kube ~/.kube
