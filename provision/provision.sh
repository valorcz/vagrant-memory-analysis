#!/bin/bash

# Update the RPM repositories first, so that we have more packages available
sudo yum install -y epel-release
sudo rpm -Uvh http://repository.it4i.cz/mirrors/repoforge/redhat/el7/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
sudo yum updateinfo

# Install the things that are available as packages, and remove things that will be replaced by PIP
sudo yum install -y vim wget python-pip gcc gcc-c++ python-devel readline-devel patch capstone git python3 python3-devel python-virtualenv radare2 strace
sudo yum remove -y PyYAML
sudo yum install -y bash-completion bash-completion-extras
sudo yum install -y python2-volatility foremost unzip yara yara-dev python2-yara libjpeg-turbo-devel
sudo yum install -y git cabextract

# pip installations, to make a few things easier.. not really a clean install, but it's fast
sudo pip install --upgrade pip
sudo pip install powerline-status distorm3
sudo pip install pefile pdbparse requests

# Prepare the VirtualEnv for Google Rekall. This allows us to use the latest available/functional version,
# and to use Python3
virtualenv ~/.venv/ --python python3
(
  source ~/.venv/bin/activate
  ln -s /usr/lib/libyara.so /home/vagrant/.venv/lib/libyara.so
  pip install --upgrade pip setuptools pyasn1 pyyaml wheel yara-python
  pip install future==0.16.0 pyaff4==0.26.post6
  pip install rekall rekall-agent

  git clone https://github.com/volatilityfoundation/volatility3 .volatility3
  cd .volatility3
  python setup.py build
  python setup.py install

  pip install oletools peepdf

  deactivate
)

# Prepare some further folder structure for our work
mkdir ~/bin/
mkdir ~/images/

# Prepare some Yara signatures
mkdir ~/yara/
(
  cd ~/yara/
  git clone https://github.com/Neo23x0/signature-base
  git clone https://github.com/Yara-Rules/rules
)

# Final touches
ln -s ~/.venv/bin/rekal ~/bin/rekal
ln -s ~/.venv/bin/vol ~/bin/vol3
ln -s ~/.venv/bin/peepdf ~/bin/peepdf

# Install the extra Volatility plugins
cp -a /vagrant/plugins ~/

cat /vagrant/bashrc >> ~/.bashrc

