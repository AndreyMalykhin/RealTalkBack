# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

environmentVars = YAML.load_file 'vagrant-environment.yml'
projectDir = "/real_talk_back"
realTalkProjectDir = projectDir + "/tools/real_talk"
provisionFile = "bootstrap.sh"
realTalkProvisionFile = "tools/real_talk/bootstrap.sh"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder ".", "/vagrant", :disabled => true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  config.vm.provider "virtualbox" do |provider, override|
    # Every Vagrant development environment requires a box. You can search for
    # boxes at https://atlas.hashicorp.com/search.
    override.vm.box = "ubuntu/trusty64"

    override.vm.hostname = environmentVars['host']

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine. In the example below,
    # accessing "localhost:8080" will access port 80 on the guest machine.
    override.vm.network "forwarded_port", guest: environmentVars['port'], host: environmentVars['virtual_machine']['host_port']

    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    override.vm.network "private_network", ip: "192.168.33.10"

    override.vm.synced_folder ".", projectDir, :nfs => true
    override.bindfs.bind_folder projectDir, projectDir

    override.vm.provision :shell, path: provisionFile, args: [projectDir, "dev", environmentVars['port'], environmentVars['host'], environmentVars['frontend_origin'], environmentVars['virtual_machine']['swap_size']]
    override.vm.provision :shell, path: realTalkProvisionFile, args: [realTalkProjectDir, "dev", environmentVars['virtual_machine']['cores_count']]

    provider.name = "real_talk_back"
    provider.cpus = environmentVars['virtual_machine']['cores_count']
    provider.memory = environmentVars['virtual_machine']['ram_size']
  end

  config.vm.provider :digital_ocean do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'

    override.vm.box = 'digital_ocean'
    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
    override.vm.synced_folder ".", projectDir, type: 'rsync', rsync__exclude: [".git/", ".vagrant/"]

    override.vm.provision :shell, path: provisionFile, args: [projectDir, "prod", environmentVars['port'], environmentVars['host'], environmentVars['frontend_origin'], environmentVars['digital_ocean']['swap_size']]
    override.vm.provision :shell, path: realTalkProvisionFile, args: [realTalkProjectDir, "prod", environmentVars['digital_ocean']['cores_count']]

    provider.token = environmentVars['digital_ocean']['token']
    provider.image = environmentVars['digital_ocean']['image']
    provider.region = environmentVars['digital_ocean']['region']
    provider.size = environmentVars['digital_ocean']['ram_size']
  end

  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
end
