#!/bin/bash

script_dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
workspace_dirname="$( cd "${script_dirname}/../.." &> /dev/null && pwd )"
rootfsdir="${workspace_dirname}/.k3s/rootfs"
k3sreadylock="${rootfsdir}/k3s-ready.lock"

if test -f "${k3sreadylock}"; then
    exit 0
fi

pushd $script_dirname

function waitssh() {
  while ! nc -z 127.0.0.1 2222; do   
    sleep 0.1
  done
  sshpass  -p 'root' ssh -o StrictHostKeychecking=no -p 2222 root@127.0.0.1 "whoami" &>/dev/null
  if [ $? -ne 0 ]; then
    sleep 1
    waitssh
  fi
}

sudo apt install netcat sshpass -y

waitssh

sshpass -p 'root' ssh -o StrictHostKeychecking=no -p 2222 root@127.0.0.1 apt-get update -y
sshpass -p 'root' ssh -o StrictHostKeychecking=no -p 2222 root@127.0.0.1 DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sshpass -p 'root' ssh -o StrictHostKeychecking=no -p 2222 root@127.0.0.1 apt-get update -y
sshpass -p 'root' ssh -o StrictHostKeychecking=no -p 2222 root@127.0.0.1 reboot

sleep 2

sshpass -p 'root' ssh -o StrictHostKeychecking=no -p 2222 root@127.0.0.1 "curl -sfL https://get.k3s.io | sh -"

mkdir -p ~/.kube
sshpass -p 'root' scp -o StrictHostKeychecking=no -P 2222 root@127.0.0.1:/etc/rancher/k3s/k3s.yaml ~/.kube/config

./kubectl.sh
kubectl get pods --all-namespaces

./helm.sh

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace --set controller.service.type=NodePort --set controller.service.nodePorts.http=32080 --set controller.service.nodePorts.https=32443

popd

touch "${k3sreadylock}"
