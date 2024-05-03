#!/bin/bash

# Update the RPM repositories first, so that we have more packages available
sudo yum install -y epel-release
#sudo rpm -Uvh http://repository.it4i.cz/mirrors/repoforge/redhat/el7/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
sudo rpm -Uvh https://repository.it4i.cz/repoforge/redhat/el7/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
sudo yum updateinfo

# Install the things that are available as packages, and remove things that will be replaced by PIP
sudo yum install -y vim wget python-pip gcc gcc-c++ python-devel readline-devel patch capstone git python3 python3-devel python-virtualenv radare2 strace
# Additional requirements to build a pyenv tool
sudo yum install -y make openssl-devel zlib-devel sqlite-devel bzip2-devel libffi-devel zlib
sudo yum install -y openssl11-devel openssl11-libs openssl11 xz-devel

# Other requirements for some of the tools below
sudo yum remove -y PyYAML
sudo yum install -y bash-completion bash-completion-extras
sudo yum install -y python2-volatility unzip yara yara-devel python2-yara libjpeg-turbo-devel
sudo yum install -y git cabextract bunzip2 p7zip
# Foremost isnt' a part of CentOS repos anymore :-/
sudo yum install -y https://forensics.cert.org/cert-forensics-tools-release-el7.rpm
sudo yum install -y foremost

# Use the last pip available for python2.7
sudo pip install --upgrade --no-cache-dir "pip < 21.0"
sudo pip install wheel
pip install powerline-status 
# distorm3 requires a c99 compatible compilation (as of 2020/11/04), thus this hack
CFLAGS="-Wall -std=c99" pip install distorm3
pip install construct==2.9.52 pefile==2019.4.18 pdbparse requests 

# PyEnv setup, so that we can have multiple Python versions
git clone https://github.com/yyuu/pyenv.git ~/.pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"

# Install python-3.11 into this Centos7 box
CPPFLAGS=-I/usr/include/openssl11 LDFLAGS=-L/usr/lib64/openssl11 pyenv install 3.11

# Prepare the VirtualEnv for Google Rekall. This allows us to use the latest available/functional version,
# and to use Python3
(
  pyenv shell 3.11
  python3 -m venv ~/.venv

  source ~/.venv/bin/activate

  pip install --upgrade pip
  pip install wheel
  pip install yara-python pycryptodome

  git clone https://github.com/volatilityfoundation/volatility3 .volatility3
  cd .volatility3
  pip install .

  # TODO: Check if we need to download symbols first

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
ln -s ~/.venv/bin/vol ~/bin/vol3
ln -s ~/.venv/bin/peepdf ~/bin/peepdf

# Install the extra Volatility plugins
cp -a /vagrant/plugins ~/

cat /vagrant/bashrc >> ~/.bashrc

