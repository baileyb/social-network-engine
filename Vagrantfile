# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.box = "ssn_development"
  config.vm.forward_port 3000, 3000
  config.vm.provision :shell, :path => "bootstrap.sh"
  config.vm.customize ["modifyvm", :id, "--memory", 1024]
  config.vm.customize ["modifyvm", :id, "--cpus", 2]
end