# Install VirtualBox
brew install --cask virtualbox
brew install --cask virtualbox-extension-pack

# Install Vagrant and the vbguest plugin to manage VirtualBox Guest Additions on the VM
brew install vagrant
vagrant plugin install vagrant-vbguest

# Install Docker CLI
brew install docker
brew install docker-compose

# Create a Vagrantfile and a provisioning script
mkdir vagrant-docker-engine
echo \
"Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/focal64'
  config.vm.hostname = 'docker.local'
  config.vm.network 'private_network', ip: '192.168.66.4'
  config.vm.network 'forwarded_port', guest: 2375, host: 2375, id: 'dockerd'
  config.vm.provider 'virtualbox' do |vb|
    vb.name = 'ubuntu-docker'
    vb.memory = '2048'
    vb.cpus = '2'
  end
  config.vm.provision 'shell', path: 'provision.sh'
  
  # Configuration for Port Forwarding
  # Uncomment or add new ones here as required
  # config.vm.network 'forwarded_port', guest: 6379, host: 6379, id: 'redis'
  # config.vm.network 'forwarded_port', guest: 3306, host: 3306, id: 'mysql'
end" | tee Vagrantfile > /dev/null
echo \
"# Install Docker
apt-get remove docker docker-engine docker.io containerd runc
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release net-tools software-properties-common
curl -fsSL <https://download.docker.com/linux/ubuntu/gpg> | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] <https://download.docker.com/linux/ubuntu> focal stable' | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Configure Docker to listen on a TCP socket
mkdir /etc/systemd/system/docker.service.d
echo \\
'[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --containerd=/run/containerd/containerd.sock' | tee /etc/systemd/system/docker.service.d/docker.conf > /dev/null
echo \\
'{
  \"hosts\": [\"fd://\", \"tcp://0.0.0.0:2375\"]
}' | tee /etc/docker/daemon.json > /dev/null
systemctl daemon-reload
systemctl restart docker.service" | tee provision.sh > /dev/null
chmod +x provision.sh

# Spin up the machine
vagrant up

# Save IP to a hostname
echo "192.168.66.4 docker.local" | sudo tee -a /etc/hosts > /dev/null

# Tell Docker CLI to talk to the VM
export DOCKER_HOST=http://docker.local:2375

# Optionally add it to your shell so don't need to repeat everytime
# echo "export DOCKER_HOST=http://docker.local:2375" | tee -a ~/.zshrc > /dev/null

# Test
docker run hello-world