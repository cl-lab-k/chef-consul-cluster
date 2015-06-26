# CHEF_DRIVER=vagrant chef-client -z destroy.rb

require 'chef/provisioning'

machine_batch do
  machines search(:node, '*:*').map { |n| n.name }
  action :destroy
end

#
# [EOF]
#
