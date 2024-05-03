FROM centos:centos7

RUN yum -y install sudo vim bzip2

RUN adduser vagrant
RUN usermod -a -G wheel vagrant
RUN echo '%wheel ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers

COPY bin /vagrant/bin
COPY plugins /vagrant/plugins
COPY signatures /vagrant/signatures
COPY bashrc /vagrant/bashrc

USER vagrant
WORKDIR /home/vagrant

COPY provision/provision.sh .
RUN sudo chmod +x provision.sh
RUN ./provision.sh

USER root
RUN rm -r provision.sh

USER vagrant
