#!/bin/bash

# Package installation section
##############################

function prepare_system_packages() {
  dnf update -y

  # Additional repos: EPEL
  dnf install epel-release -y
  dnf config-manager --set-enabled epel

  dnf group install -y "Development Tools"
  
  dnf install -y libffi-devel zlib zlib-devel bzip2-devel openssl-devel sqlite-devel readline-devel \
                 libjpeg-turbo-devel unzip yara cabextract bzip2 p7zip radare2 strace \
                 git glibc-langpack-en glibc-locale-source
}

# pyenv installation, due to Volatility,
# both version
function prepare_pyenv() {
  curl https://pyenv.run | bash
  # Prepare the pyenv supporting environment, so that we can use it right away
  eval "$(pyenv init -)"
}

function setup_volatility2() {
  eval "$(pyenv init -)"
  pyenv install 2.7 # 2.7.18

  # Create a specific virtualenv
  pyenv shell 2.7
  pyenv virtualenv py2

  (
    pyenv shell py2

    pip install --upgrade pip
    pip install wheel
    pip install pefile==2019.4.18 construct==2.9.52 yara-python pycryptodome distorm3 pdbparse requests

    git clone https://github.com/volatilityfoundation/volatility .volatility2

    cd .volatility2 || return
    pip install .
  )
}

function setup_volatility3() {
  eval "$(pyenv init -)"
  pyenv install 3.12

  # Create a specific virtualenv
  pyenv shell 3.12
  pyenv virtualenv py3

  (
    pyenv shell py3

    pip install --upgrade pip
    pip install wheel
    pip install yara-python pycryptodome requests

    git clone https://github.com/volatilityfoundation/volatility3 .volatility3

    cd .volatility3 || return
    pip install .
  )
}

# All the things that are useful, and need a setup
function setup_additional_tools() {
  (
    eval "$(pyenv init -)"
    pyenv shell py3

    # Additional analysis tools for Office and PDF docs
    pip install oletools peepdf
  )
}
  
# Prepare some Yara signatures
# TODO: Make this optional
function setup_yara_signatures() {
  # This is our crafted signature for one of the exercises
  cp /vagrant/signatures/suspicious_domain.yara ~/yara/

  # Download other signatures from internet
  (
    cd ~/yara/ || return
    git clone https://github.com/Neo23x0/signature-base
    git clone https://github.com/Yara-Rules/rules
  )
}

# create the folders we need for our seminar
function setup_folders() {
  # Basic folders
  mkdir ~/bin/
  mkdir ~/images/
  mkdir ~/yara/

  # Install the extra Volatility plugins
  cp -a /vagrant/plugins ~/

  # Link the python2 binaries
  ln -s ~/.pyenv/versions/py2/bin/vol.py ~/bin/vol

  # Link the python3 binaries
  ln -s ~/.pyenv/versions/py3/bin/vol  ~/bin/vol3
  ln -s ~/.pyenv/versions/py3/bin/peepdf ~/bin/peepdf
}

function setup_bashrc() {
  cat /vagrant/bashrc >> ~/.bashrc
}

# Put it all together
function setup_environment() {
  # System stuff
  prepare_system_packages
  prepare_pyenv

  # Various tools installation
  setup_volatility2
  setup_volatility3
  setup_additional_tools

  # Final touches
  setup_folders
  setup_bashrc

  # In case we need them, but mostly we don't
  setup_yara_signatures

  # Ensure Volatility 3 symbols mountpoint exists
  setup_volatility3_symbols
}

function setup_volatility3_symbols() {
  mkdir -p "${HOME}/.local/share/volatility3/symbols"
}

export PATH="~/.pyenv/bin:$PATH"
