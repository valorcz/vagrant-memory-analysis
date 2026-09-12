#!/usr/bin/env -S docker buildx build . --tag=valorcz/pv204_memory_analysis:latest --network=host --file
FROM almalinux:9

LABEL maintainer="Vaclav Lorenc <vaclav.lorenc@gmail.com>"

SHELL ["/bin/bash", "-c"]

RUN dnf -y install sudo vim bzip2 && \
    adduser vagrant && \
    usermod -a -G wheel vagrant && \
    echo '%wheel ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers

# System package installation runs natively as root (avoids QEMU setuid sudo issues)
COPY provision/provision-docker.sh /tmp/provision-docker.sh
RUN source /tmp/provision-docker.sh && prepare_system_packages

# Prepare the /vagrant source structure
COPY bin /vagrant/bin
COPY plugins /vagrant/plugins
COPY signatures /vagrant/signatures
COPY bashrc /vagrant/bashrc
RUN chown -R vagrant:vagrant /vagrant

# Switch to vagrant user for userland toolchain (pyenv, pip, virtual environments)
USER vagrant
WORKDIR /home/vagrant

COPY --chown=vagrant:vagrant provision/provision-docker.sh .

# Toolchain installation
RUN source provision-docker.sh && prepare_pyenv
RUN source provision-docker.sh && setup_volatility2
RUN source provision-docker.sh && setup_volatility3
RUN source provision-docker.sh && setup_additional_tools

# Final touches
RUN source provision-docker.sh && setup_folders
RUN source provision-docker.sh && setup_bashrc

USER root
RUN rm -f /tmp/provision-docker.sh /home/vagrant/provision-docker.sh

USER vagrant

