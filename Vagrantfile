# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.provision :shell, path: "provision/init.sh"
  config.vm.provision :shell, path: "provision/always.sh", run: "always"
  config.vm.network :forwarded_port, guest: 80, host: 80
end