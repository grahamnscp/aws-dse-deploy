#!/usr/bin/bash

sudo yum makecache fast
yum install -y vim-enhanced

echo "alias l='ls -latFrh'" >> /home/centos/.bashrc
echo "set background=dark"  >> /home/centos/.vimrc
echo "syntax on"            >> /home/centos/.vimrc
echo "alias l='ls -latFrh'" >> /root/.bashrc
echo "set background=dark"  >> /root/.vimrc
echo "syntax on"            >> /root/.vimrc

sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
setenforce 0


