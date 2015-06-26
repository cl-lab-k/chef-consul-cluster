#
# Rakefile Name:: chef-consul-cluster
#
# Copyright (c) 2015 CREATIONLINE,INC. All Rights Reserved.
#

require 'json'

#
# setting
#
config = JSON.parse(
  File.read(
    File.join( File.dirname(__FILE__), 'provisioning', 'chef.json' )
  )
)

chef_server_fqdn   = config['chef-server']['api_fqdn']
chef_server_ipaddr = config['chef-server']['api_fqdn']

user_name  = config['chef-user']['user_name']
first_name = config['chef-user']['first_name']
last_name  = config['chef-user']['last_name']
mail_addr  = config['chef-user']['mail_addr']
password   = config['chef-user']['password']
org_name   = config['chef-user']['org_name']
org_full   = config['chef-user']['org_full_name']

priv_key = '~/.chef/vms/.vagrant/machines/chef-server/virtualbox/private_key'

chef_dir = File.join( File.dirname(__FILE__), '.chef' )
user_key = File.join( chef_dir, "#{user_name}.pem" )
org_key  = File.join( chef_dir, "#{org_name}-validator.pem" )
knife_rb = File.join( chef_dir, 'knife.rb' )
crt      = File.join( chef_dir, 'trusted_certs', chef_server_fqdn.gsub( /\./, '_' ), '.crt' )

#
# configurations
#
desc 'mkdir .chef dir'
task :chef_dir => chef_dir
file chef_dir do
  sh "mkdir #{chef_dir}"
end

desc 'gen/get user key'
task :user_key => [ :chef_dir, user_key ]
file user_key do
  sh "ssh -i #{priv_key} vagrant@#{chef_server_ipaddr}" +
     " 'sudo chef-server-ctl user-create #{user_name}" +
     " #{first_name} #{last_name} #{mail_addr} #{password}" +
     " --filename #{user_name}.pem'"
  sh "scp -i #{priv_key} vagrant@#{chef_server_ipaddr}:#{user_name}.pem #{user_key}"
end

desc 'gen/get org key'
task :org_key => [ :chef_dir, org_key ]
file org_key do
  sh "ssh -i #{priv_key} vagrant@#{chef_server_ipaddr}" +
     " 'sudo chef-server-ctl org-create #{org_name} #{org_full}" +
     " --association #{user_name} --filename #{org_name}-validator.pem'"
  sh "scp -i #{priv_key} vagrant@#{chef_server_ipaddr}:#{org_name}-validator.pem #{org_key}"
end

desc 'gen knife.rb'
task :knife_rb => [ :chef_dir, knife_rb ]
file knife_rb do
  sh %Q|touch #{knife_rb}|
  sh %Q|echo 'current_dir = File.dirname(__FILE__)' >> #{knife_rb}|
  sh %Q|echo 'chef_server_url "https://#{chef_server_fqdn}/organizations/#{org_name}"' >> #{knife_rb}|
  sh %Q|echo 'node_name "#{user_name}"' >> #{knife_rb}|
  sh %Q|echo 'client_key "\#{current_dir}/#{user_name}.pem"' >> #{knife_rb}|
  sh %Q|echo 'validation_client_name "#{org_name}"' >> #{knife_rb}|
  sh %Q|echo 'validation_key "\#{current_dir}/#{org_name}-validator.pem"' >> #{knife_rb}|
end

task :crt => crt
desc 'knife ssl fetch'
file crt do
  sh 'knife ssl fetch'
end

#
# berkshelf
#
desc 'berks vendor'
task :vendor do
  sh 'berks vendor cookbooks'
end

desc 'berks upload'
task :upload do
  sh 'berks upload --no-ssl-verify --force'
end

#
# knife role
#
desc 'knife role upload'
task :role do
  sh "knife role from file roles/chef-consul-cluster-*.json"
end

#
# knife ssh
#
desc 'run chef-client'
task :converge do
  sh "knife ssh 'name:*' -x vagrant -P vagrant 'sudo chef-client'"
end

desc 'run consul members'
task :consul_members do
  sh "LANG=C LC_ALL=C knife ssh 'name:*' -x vagrant -P vagrant 'consul members'"
end

task :config => [ :user_key, :org_key, :knife_rb, :crt, :vendor, :upload, :role ]
task :default => :converge
#
# [EOF]
#
