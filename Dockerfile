FROM almalinux:9

SHELL ["/bin/bash", "-c"] 

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

COPY provision/provision-el9.sh .
RUN sudo chmod +x provision-el9.sh
RUN ./provision-el9.sh

USER root
RUN rm -r provision-el9.sh

USER vagrant
