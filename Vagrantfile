# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

$script = <<-SCRIPT
curl -sSL https://get.docker.com/ | sh
# Add vagrant user to the docker group
usermod -a -G docker vagrant
diff -q /etc/systemd/system/multi-user.target.wants/docker.service /home/vagrant/docker.service || cp /home/vagrant/docker.service /etc/systemd/system/multi-user.target.wants/docker.service
systemctl daemon-reload
systemctl restart docker.service
echo "192.168.100.2 docker.local" | sudo tee -a /etc/hosts > /dev/null
echo "export DESARROLLO=/home/vagrant/Desarrollo" | sudo tee -a /etc/profile > /dev/null
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  # Checkea las opciones aqui https://www.vagrantup.com/docs/networking/private_network
  config.vm.network "private_network", ip: "192.168.100.2"
  #Para modo bridge
  #config.vm.network "public_network", bridge: "Realtek PCIe GbE Family Controller"
  config.vm.synced_folder "~/Desarrollo", "/home/vagrant/Desarrollo"
  config.vm.provider :parallels do |prl|
    prl.memory = "2048"
  end

  config.vm.provision "file", source: "docker.service", destination: "/home/vagrant/docker.service"
  config.vm.provision :shell, :inline => $script
  
end
