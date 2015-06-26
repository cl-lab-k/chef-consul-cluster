#
# Cookbook Name:: chef-consul-cluster
# Recipe:: default
#
# Copyright (c) 2015 CREATIONLINE,INC. All Rights Reserved.
#

include_recipe 'nginx::default'

file '/etc/nginx/sites-available/lb211' do
  owner 'root'
  group 'root'
  mode 0644
  content <<_CONTENT_
upstream lb_units {
	server web.service.consul;
}

server {
	listen 80;
	server_name lb211;
	location / {
		proxy_pass http://lb_units;
		proxy_set_header Host $http_host;
	}
}
_CONTENT_
end

nginx_site 'default' do
  enable false
end

nginx_site 'lb211' do
  enable true
end

#
# [EOF]
#
