#!/bin/bash

# Update the RPM repositories first, so that we have more packages available
sudo yum install -y epel-release
sudo rpm -Uvh http://repository.it4i.cz/mirrors/repoforge/redhat/el7/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
sudo yum updateinfo

# Install the things that are available as packages, and remove things that will be replaced by PIP
sudo yum install -y vim wget python-pip gcc gcc-c++ python-devel readline-devel patch capstone git python3 python3-devel python-virtualenv radare2
sudo yum remove -y PyYAML
sudo pip install powerline-status distorm3
sudo yum install -y bash-completion bash-completion-extras
sudo yum install -y python2-volatility foremost unzip

# Prepare the VirtualEnv for Google Rekall. This allows us to use the latest available/functional version,
# and to use Python3
virtualenv ~/.venv/ --python python3
source ~/.venv/bin/activate
pip install --upgrade pip setuptools pyasn1 pyyaml wheel
pip install future==0.16.0 pyaff4==0.26.post6
pip install rekall rekall-agent
deactivate

# Prepare some further folder structure for our work
mkdir ~/bin/
mkdir ~/images/

# Final touches
ln -s ~/.venv/bin/rekal ~/bin/rekal
cat /vagrant/bashrc >> ~/.bashrc

