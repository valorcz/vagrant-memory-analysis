#!/bin/bash

# Package installation section
##############################

function prepare_system_packages() {
  sudo dnf update -y
  # We may need to restart after, not sure how to make this happen

  # Additional repos: EPEL
  sudo dnf install epel-release -y
  sudo dnf config-manager --set-enabled epel

  # This, however, may install a plenty of unnecessary packages,
  # I may need to cut it down to speed up the builds
  sudo dnf group install -y "Development Tools"
  
  # We are missing yara-devel, may or may not be a problem
  sudo dnf install -y libffi-devel zlib zlib-devel bzip2-devel openssl-devel sqlite-devel readline-devel \
                      libjpeg-turbo-devel unzip yara cabextract bzip2 p7zip radare2 strace
}

# pyenv installation, due to Volatility,
# both version
function prepare_pyenv() {
  curl https://pyenv.run | bash
  # Read the pyenv supporting environment, so that we can use it right away
  source /vagrant/provision/provision-pyenv.sh
}

function setup_volatility2() {
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
}


# TODO: Create a main() function with some helps and hints
setup_environment

