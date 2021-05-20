#!/bin/bash

# Update the RPM repositories first, so that we have more packages available
sudo yum install -y epel-release
sudo rpm -Uvh http://repository.it4i.cz/mirrors/repoforge/redhat/el7/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
sudo yum updateinfo

# Install the things that are available as packages, and remove things that will be replaced by PIP
sudo yum install -y vim wget python-pip gcc gcc-c++ python-devel readline-devel patch capstone git python3 python3-devel python-virtualenv radare2 strace
sudo yum remove -y PyYAML
sudo yum install -y bash-completion bash-completion-extras
sudo yum install -y python2-volatility unzip yara yara-devel python2-yara libjpeg-turbo-devel
sudo yum install -y git cabextract
# Foremost isnt' a part of CentOS repos anymore :-/
sudo yum install -y https://forensics.cert.org/cert-forensics-tools-release-el7.rpm
sudo yum install -y foremost

sudo pip install --upgrade --no-cache-dir "pip < 21.0"
sudo pip install wheel
pip install powerline-status 
# distorm3 requires a c99 compatible compilation (as of 2020/11/04), thus this hack
CFLAGS="-Wall -std=c99" pip install distorm3
pip install construct==2.9.52 pefile==2019.4.18 pdbparse requests 

# Prepare the VirtualEnv for Google Rekall. This allows us to use the latest available/functional version,
# and to use Python3
virtualenv ~/.venv/ --python python3
(
  source ~/.venv/bin/activate
  ln -s /usr/lib/libyara.so /home/vagrant/.venv/lib/libyara.so
  pip install --upgrade pip
  pip install setuptools pyasn1 pyyaml wheel yara-python
  pip install construct==2.9.52 pdbparse
  pip install future==0.16.0 pyaff4==0.26.post6
  pip install rekall rekall-agent

  git clone https://github.com/volatilityfoundation/volatility3 .volatility3
  cd .volatility3
  python setup.py build
  python setup.py install

  pip install oletools peepdf

  deactivate
)

# Patch the discontinued Rekall agent to work a bit at least
patch ~/.venv/lib/python3.6/site-packages/rekall_agent/agent.py /vagrant/provision/rekal_agent.patch

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

