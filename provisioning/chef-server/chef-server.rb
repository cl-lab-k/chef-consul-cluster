# CHEF_DRIVER=vagrant chef-client -z chef-server.rb

require 'chef/provisioning'

#
# setting
#
config = JSON.parse(
  File.read(
    File.join( File.dirname(__FILE__), '..', 'chef.json')
  )
)

repo_dir = File.dirname(__FILE__)
with_chef_local_server(
  chef_repo_path: repo_dir,
  cookbook_path: File.join( repo_dir, 'cookbooks' )
)

with_machine_options :vagrant_options => {
  'vm.box' => 'chef/ubuntu-14.04'
}

chef_server_fqdn = config['chef-server']['api_fqdn']
chef_server_name = chef_server_fqdn.sub( /\..*$/, '' )

#
# chef-server
#
machine 'chef-server' do
  add_machine_options(
    :vagrant_config => <<-_CONFIG_
    config.vm.network 'private_network', ip: '#{config['chef-server']['ipaddr']}'
    config.vm.provider "virtualbox" do |v|
      v.memory = 4096
    end
    config.vm.hostname = "#{chef_server_name}"
    config.hostsupdater.aliases = [ "#{chef_server_fqdn}" ]
_CONFIG_
  )
  attributes config

  recipe 'chef-server::default'
end

#
# [EOF]
#
