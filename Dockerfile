#!/usr/bin/env -S docker buildx build . --tag=valorcz/pv204_memory_analysis:latest --network=host --file
FROM almalinux:9

LABEL maintainer="Vaclav Lorenc <vaclav.lorenc@gmail.com>"

RUN dnf -y install sudo vim bzip2

RUN adduser vagrant
RUN usermod -a -G wheel vagrant
RUN echo '%wheel ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers

# Prepare the source structure
COPY bin /vagrant/bin
COPY plugins /vagrant/plugins
COPY signatures /vagrant/signatures
COPY bashrc /vagrant/bashrc

USER vagrant
WORKDIR /home/vagrant

COPY provision/provision-docker.sh .

# Make sure we use bash as the provisioning shell
SHELL ["/bin/bash", "-c"] 

# System stuff
RUN source provision-docker.sh && prepare_system_packages
RUN source provision-docker.sh && prepare_pyenv

# Various tools installation
RUN source provision-docker.sh && setup_volatility2
RUN source provision-docker.sh && setup_volatility3
RUN source provision-docker.sh && setup_additional_tools

# Final touches
RUN source provision-docker.sh && setup_folders
RUN source provision-docker.sh && setup_bashrc

USER root
RUN rm -r provision-docker.sh

USER vagrant
