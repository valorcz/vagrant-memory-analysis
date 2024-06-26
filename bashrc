# Colors

RED='\033[0;37;41m'
NC='\033[0m' # No Color

export LC_ALL=en_US.UTF-8
export PATH=$PATH:~/bin/:~/.venv/bin/:~/.pyenv/bin/
export VOLATILITY_PLUGINS=/home/vagrant/plugins/

# Source some extra files
#source ~/.local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh
source /vagrant/bin/examples.sh

# Install the bash-completions to make the VM easier to work with
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
  . /usr/share/bash-completion/bash_completion

# Initialize pyenv toolchain
eval "$(pyenv init -)"
