# CHEF_DRIVER=vagrant chef-client -z vms.rb

require 'chef/provisioning'

#
# setting
#
config = JSON.parse(
  File.read(
    File.join( File.dirname(__FILE__), '..', 'chef.json' )
  )
)

chef_server_fqdn   = config['chef-server']['api_fqdn']
chef_server_ipaddr = config['chef-server']['ipaddr']

network  = chef_server_ipaddr.sub( /\.\d{1,3}$/, '.' )
org_name = config['chef-user']['org_name']

with_chef_server(
  "https://#{chef_server_fqdn}/organizations/#{org_name}",
  :client_name => Chef::Config[:node_name],
  :signing_key_filename => Chef::Config[:client_key]
)

with_machine_options :vagrant_options => {
  'vm.box' => 'chef/ubuntu-14.04'
}

#
# vms info
#
vms = [ 'srv101', 'srv102', 'srv103', 'node201', 'node202', 'lb211' ]

etc_hosts = <<_CONTENT_
127.0.0.1	localhost
#{chef_server_ipaddr}	#{chef_server_fqdn}
_CONTENT_
vms.each do |s|
  etc_hosts << "#{network}#{s.sub(/^[a-z]+/,'')}	#{s}\n"
end

#
# vms
#
machine_batch do
  vms.each do |s|
    machine s do
      add_machine_options(
    :vagrant_config => <<-_CONFIG_
    config.vm.provider "virtualbox" do |v|
      v.memory = 1024
    end
    config.vm.network :private_network, ip: '#{network}#{s.sub(/^[a-z]+/,'')}'
    config.vm.hostname = "#{s}"
    config.cache.scope = :box
_CONFIG_
      )

      # https://github.com/chef/chef-provisioning/issues/237
      crt = File.join( 'trusted_certs',
                       chef_server_fqdn.gsub( /\./, '_' ) + '.crt' )
      file "/etc/chef/#{crt}",
           File.join( File.dirname(__FILE__), '..', '..', '.chef', crt )

      file '/etc/hosts' => { :content => etc_hosts }

      case s
      when /^srv/
        role 'chef-consul-cluster-server'
      when /^node/
        role 'chef-consul-cluster-client'
      when /^lb/
        role 'chef-consul-cluster-lb'
      end
    end
  end
end

#
# [EOF]
#
