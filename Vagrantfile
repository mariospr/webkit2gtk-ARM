# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/wily64"
  config.vm.box_check_update = false

  # Path to the WebKit checkout (adjust as needed)
  config.vm.synced_folder "/home/mario/work/endless/github/WebKit-arm", "/home/vagrant/WebKitARM"

  # Path to the target RootFS (adjust as needed)
  config.vm.synced_folder "/schroot/eos-master-armhf", "/schroot/eos-master-armhf"

  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = "12228"
  end

  # Bootstraping the machine: Install packages and copy the CMake Toolchain file
  config.vm.provision "shell", path: "bootstrap.sh"
  config.vm.provision "file", source: "armv7l-toolchain.cmake", destination: "armv7l-toolchain.cmake"
end
