#
# Cookbook Name:: zwift
# Recipe:: attr-remap
#
# Copyright 2012, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


# pull the management host, for lookups later
nodelist = get_nodes_by_recipe("zwift::admin-server")
admin_node = nil
if nodelist.length > 0
  admin_node = nodelist[0]
end


# swift-lite will set the /etc/swift/swift.conf
node.default["swift"]["swift_hash_suffix"] = node["zwift"]["swift_common"]["swift_hash_suffix"]
node.default["swift"]["swift_hash_prefix"] = node["zwift"]["swift_common"]["swift_hash_prefix"]

# make exnet and public map to the right underlying networks
node.default["osops_networks"]["swift-storage"] = node["zwift"]["network"]["management"]
node.default["osops_networks"]["swift-replication"] = node["zwift"]["network"]["management"]
node.default["osops_networks"]["swift-management"] = node["zwift"]["network"]["management"]
node.default["osops_networks"]["swift-proxy"] = node["zwift"]["network"]["management"]

# pass through the proxy args
node.default["swift"]["proxy"]["pipeline"] = node["zwift"]["proxy"]["pipeline"]

# set up memcache
node.default["memcached"]["memory"] = node["zwift"]["proxy"]["memcache_maxmem"]
node.default["memcached"]["maxconn"] = node["zwift"]["proxy"]["sim_connections"]

node.default["memcached"]["services"]["cache"]["network"] = "swift-storage"
node.default["swift"]["memcache_role"] = "spc-starter-proxy"
node.default["swift"]["ntp"]["role"] = "spc-starter-controller"



# set the git repo location where the git cookbook expects it
node.default["git"]["server"]["base_path"] = node["zwift"]["versioning"]["repository_base"]

# point remote syslog to admin machine if not overridden/specified
#
# FIXME: this is pretty questionable... we need to fix up the osops-utils
# stuff to work righter by recipe
#
if not node["zwift"]["swift_common"]["syslog_ip"]
  if not admin_node
    raise "Must specify zwift/swift_common/syslog_ip"
  end

  node.default["zwift"]["swift_common"]["syslog_ip"] = get_ip_for_net("swift-management", admin_node)
end

# keystone setup.  This will only do anything interesting if the keystone
# recipe is applied.

node.default["keystone"]["pki"]["enabled"] = node["zwift"]["keystone"]["pki"]

if not node["zwift"]["keystone"]["keystone_admin_url"]
  if not admin_node
    raise "Must specify keystone endpoints"
  end

  my_keystone_ip = get_ip_for_net("swift-management", admin_node)

  node.default["zwift"]["keystone"]["keystone_admin_url"] = "http://#{my_keystone_ip}:35357/v2.0"
  node.default["zwift"]["keystone"]["keystone_internal_url"] = "http://#{my_keystone_ip}:5000/v2.0"
  node.default["zwift"]["keystone"]["keystone_public_url"] = "http://#{my_keystone_ip}:5000/v2.0"
end

if not node["zwift"]["keystone"]["auth_password"]
  raise "Must supply swift/keystone/auth_password"
end

node.default["swift"]["keystone_endpoint"] = node["zwift"]["keystone"]["keystone_public_url"]


node.default["swift"]["service_user"] = node["zwift"]["keystone"]["auth_user"]
node.default["swift"]["service_pass"] = node["zwift"]["keystone"]["auth_password"]
node.default["swift"]["service_tenant_name"] = node["zwift"]["keystone"]["auth_tenant"]

# set up the git host ip - pull the ip from the management box
if not node["zwift"]["versioning"]["repository_host"]
  if not admin_node
    raise "Must specify zwift/versioning/repository_host"
  end

  node.default["zwift"]["versioning"]["repository_host"] = get_ip_for_net("swift-management", admin_node)
end
