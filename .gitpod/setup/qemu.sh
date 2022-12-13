#!/bin/bash

sudo apt update -y
sudo apt upgrade -y
sudo apt update -y
sudo apt install qemu qemu-system-x86 linux-image-generic libguestfs-tools sshpass netcat -y
