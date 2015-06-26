#
# Cookbook Name:: chef-consul-cluster
# Recipe:: default
#
# Copyright (c) 2015 CREATIONLINE,INC. All Rights Reserved.
#

package 'curl'

include_recipe 'nginx::default'

directory '/var/www/nginx-default' do
  owner 'root'
  group 'root'
  mode 0755
  recursive true
end

file '/var/www/nginx-default/index.html' do
  owner 'root'
  group 'root'
  mode 0644
  content <<_CONTENT_
<html><body><h1>#{node['fqdn']}</h1></body></html>
_CONTENT_
end

file File.join( node['consul']['config_dir'], '/web.json' ) do
  owner node['consul']['service_user']
  group node['consul']['service_group']
  mode 0644
  notifies :restart, 'service[consul]'
  content <<_CONTENT_
{
  "service": {
    "name": "web",
    "tags": [ "test" ],
    "port": 80,
    "check": {
      "script": "curl http://127.0.0.1:80/ > /dev/null 2> /dev/null",
      "interval": "10s",
      "timeout": "5s"
    }
  }
}
_CONTENT_
end

#
# [EOF]
#
