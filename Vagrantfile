# -*- mode: ruby -*-
# vi: set ft=ruby :

#  Getting Started:
#  See README.md in this directory
#---------------------------------#
#  Cheat Sheet:
#---------------------------------#
#  vagrant up
#  vagrant ssh xfiles
#  ~/xfiles/xbootstrap/config-linux.sh
#  source ~/.bash_profile
#  open nvim to install plugins
#
#  https://stackoverflow.com/questions/2500436/how-does-cat-eof-work-in-bash
#  ^^^ that link describes how the SSHEOF part works below

Vagrant.configure(2) do |config|
  config.hostmanager.enabled = true
  config.hostmanager

  config.vm.define "xfiles", primary: true do |h|
    h.vm.box = "bento/centos-7"
    #h.vm.box = "bento/ubuntu-18.04"

    h.vm.synced_folder ".", "/home/vagrant/xfiles_staging"
    h.vm.hostname = "xfiles"
    h.vm.network "private_network", ip: "192.168.23.10"
    h.vm.provision :shell, inline: 'yum install -y git epel-release'
    #h.vm.provision :shell, inline: 'apt-get install -y git'
    h.vm.provision :shell, inline: 'chmod +x /home/vagrant/xfiles_staging/xbootstrap/*.sh'
    h.vm.provision :shell, inline: 'cp -rf /home/vagrant/xfiles_staging /home/vagrant/xfiles'
    h.vm.provision :shell, inline: 'chown -R vagrant:vagrant /home/vagrant/xfiles'

    h.vm.provision :shell, :inline => <<'EOF'
if [ ! -f "/home/vagrant/.ssh/id_rsa" ]; then
  ssh-keygen -t rsa -N "" -f /home/vagrant/.ssh/id_rsa
fi
mkdir -p /vagrant
cp /home/vagrant/.ssh/id_rsa.pub /vagrant/control.pub

cat << 'SSHEOF' > /home/vagrant/.ssh/config
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
SSHEOF

chown -R vagrant:vagrant /home/vagrant/.ssh/
chmod +x /home/vagrant/xfiles/config/shell/*.*sh
EOF
  end
end