Vagrant.configure('2') do |config|
  # vagrant plugin install vagrant-hostmanager
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.vm.define 'host01' do |host01|
    host01.vm.box = 'centos/7'
    host01.vm.hostname = 'host01'
    host01.vm.box_url = 'bento/centos-6.7'
    host01.vm.network :private_network, ip: '192.168.11.11'
    # host01.vm.network 'forwarded_port', guest: 9990, host: 9990
    host01.vm.provider :virtualbox do |v|
      v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
      v.customize ['modifyvm', :id, '--memory', 2048]
      v.customize ['modifyvm', :id, '--name', 'host01']
    end
  end
  config.vm.define 'host02' do |host02|
    #host02.vm.box = 'bento/centos-6.7'
    host02.vm.box = 'centos/7'
    host02.vm.hostname = 'host02'
    host02.vm.box_url = 'bento/centos-6.7'
    host02.vm.network :private_network, ip: '192.168.11.12'
    # host01.vm.network 'forwarded_port', guest: 9990, host: 9990
    host02.vm.provider :virtualbox do |v|
      v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
      v.customize ['modifyvm', :id, '--memory', 2048]
      v.customize ['modifyvm', :id, '--name', 'host02']
    end
  end

  # config.vm.define 'foundation1' do |foundation1|
  #   foundation1.vm.box = 'bento/centos-6.7'
  #   foundation1.vm.hostname = 'deheremap6845.emea.adsint.biz'
  #   foundation1.vm.box_url = 'bento/centos-6.7'
  #   foundation1.vm.network :private_network, ip: '192.168.11.11'
  #   # foundation1.vm.network 'forwarded_port', guest: 9990, host: 9991
  #   foundation1.vm.provider :virtualbox do |v|
  #     v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
  #     v.customize ['modifyvm', :id, '--memory', 4096]
  #     v.customize ['modifyvm', :id, '--name', 'foundation1']
  #   end
  # end

  config.vm.provider :virtualbox do |vb|
    # This allows symlinks to be created within the /vagrant root directory,
    # which is something librarian-puppet needs to be able to do. This might
    # be enabled by default depending on what version of VirtualBox is used.
    vb.customize ['setextradata', :id, 'VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root', '1']
    vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional', '--draganddrop', 'bidirectional']
  end
  #config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  config.vm.provision :shell do |shell| # user
    shell.path = 'shell/user.sh'
    shell.args = ''
  end

  # ssh
 # config.vm.provision :shell do |shell|
 #   shell.path = 'shell/vagrant_bootstrap.sh'
 #   shell.args = '-r foundationservices_install -e sit -a 201801.SIT -t FoundationService -d'
 # end
  # config.vm.provision :shell do |shell|
  #   shell.path = 'shell/vagrant_bootstrap.sh'
  #   shell.args = '-r elasticsearch_install -e goa -a 201801.DEV -t ElasticSearch -d'
  # end

end