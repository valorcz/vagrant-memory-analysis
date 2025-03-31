# -*- mode: ruby -*-
# vi: set ft=ruby :

# TODO: We probably don't need this. Either we detect arm64, then proceed
# with qemu/aarch64 way, or we can use VirtualBox
def running_rosetta()
  !`sysctl -in sysctl.proc_translated`.strip().to_i.zero?
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  arch = `arch`.strip()

  config.vm.box = "generic/alma9"

  # Apple Silicon/aarch64: This setup is specific for aarch64 platforms
  #                        so that we don't need to emulate x86_64

  if arch == "arm64"
    # puts 'Provisioning arm64 code'

    config.vm.box_architecture = "arm64"

    config.vm.provider "qemu" do |qe|
     qe.arch = "aarch64"
     qe.ssh_port = "50024"
     qe.cpu = "max"
    end
  end

  # Specific Vagrant configuration for Virtualbox
  config.vm.provider "virtualbox" do |vb|
     # Customize the amount of memory on the VM:
     vb.memory = "1024"
     vb.cpus = "2"
     # Try to prevent vbguest upgrade issues
     if Vagrant.has_plugin?("vagrant-vbguest")
       config.vbguest.auto_update = false
     end
  end

  config.vm.synced_folder ".", "/vagrant", type: "rsync",
    rsync__exclude: [".git/", "images", "samples", "slides", "symbols"]

  # View the documentation for the provider you are using for more
  # information on available options.
  config.vm.hostname = "memory-analysis"

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", privileged: false, path: "provision/provision-el9.sh"
end

