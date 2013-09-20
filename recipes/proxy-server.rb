#
# Cookbook Name:: zwift
# Recipe:: proxy-server
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

#include_recipe "zwift::attr-remap"
include_recipe "zwift::common"
include_recipe "swift-lite::proxy-server"

common = node["zwift"]["swift_common"]

# find memcache servers and keystone endpoint
memcache_endpoints = get_realserver_endpoints(node["swift"]["memcache_role"], "memcached", "cache")

memcache_servers = memcache_endpoints.collect do |endpoint|
  "#{endpoint["host"]}:#{endpoint["port"]}"
end.join(",")

# FIXME(rp)
# this could likely be obtained from the native zwift stuff
swift_settings = node["swift"] unless get_settings_by_recipe("swift-lite::setup", "swift") != nil

if swift_settings.has_key?("keystone_endpoint")
  keystone_auth_uri = swift_settings["keystone_endpoint"]
else
  ks_admin = get_access_endpoint(node["keystone"]["api_role"], "keystone", "admin-api")
  keystone_auth_uri = ks_admin.uri
end

keystone_uri = URI(keystone_auth_uri)


# For more configurable options and information please check either proxy-server.conf manpage
# or proxy-server.conf-sample provided within the distributed package 
default_options = {
  "DEFAULT" => {
    "bind_ip" => "0.0.0.0",
    "bind_port" => "8080",
    "backlog" => "4096",
    "workers" => 12
  },
  "pipeline:main" => {
    "pipeline" => "catch_errors proxy-logging healthcheck cache ratelimit proxy-logging proxy-server"
  },
  "app:proxy-server" => {
    "use" => "egg:swift#proxy",
    "log_facility" => "LOG_LOCAL0",
    "node_timeout" => "60",
    "client_timeout" => "60",
    "conn_timeout" => "3.5",
    "allow_account_management" => "false",
    "account_autocreate" => "true"
  },
  "filter:proxy-query" => {
    "use" => "egg:zerocloud#proxy_query",
    "zerovm_maxinput" => "5368709120",
    "zerovm_maxoutput" => "5368709120"
  },
  "filter:healthcheck" => {
    "use" => "egg:swift#healthcheck"
  },
  "filter:cache" => {
    "use" => "egg:swift#memcache",
    "memcache_serialization_support" => "2",
    "memcache_servers" => memcache_servers
  },
  "filter:ratelimit" => {
    "use" => "egg:swift#ratelimit"
  },
  "filter:domain_remap" => {
    "use" => "egg:swift#domain_remap"
  },
  "filter:catch_errors" => {
    "use" => "egg:swift#catch_errors"
  },
  "filter:cname_lookup" => {
    "use" => "egg:swift#cname_lookup"
  },
  "filter:staticweb" => {
    "use" => "egg:swift#staticweb"
  },
  "filter:tempurl" => {
    "use" => "egg:swift#tempurl"
  },
  "filter:formpost" => {
    "use" => "egg:swift#tempurl"
  },
  "filter:name_check" => {
    "use" => "egg:swift#name_check"
  },
  "filter:list-endpoints" => {
    "use" => "egg:swift#list_endpoints"
  },
  "filter:proxy-logging" => {
    "use" => "egg:swift#proxy_logging"
  },
  "filter:bulk" => {
    "use" => "egg:swift#bulk"
  },
  "filter:container-quotas" => {
    "use" => "egg:swift#container_quotas"
  },
  "filter:slo" => {
    "use" => "egg:swift#slo"
  },
  "filter:account-quotas" => {
    "use" => "egg:swift#account_quotas"
  }
}

overrides = { "DEFAULT" => node["zwift"]["swift_common"].select { |k, _| k.start_with?("log_statsd_") }}

if node["zwift"]["proxy"] and node["zwift"]["proxy"]["config"]
  overrides = overrides.merge(node["zwift"]["proxy"]["config"]) { |k, x, y| x.merge(y) }
end

resources("template[/etc/swift/proxy-server.conf]").instance_exec do
  cookbook "zwift"
  source "inifile.conf.erb"
  mode "0644"
  variables("config_options" => default_options.merge(overrides) { |k, x, y| x.merge(y) })
end

packages = [ "python-zerocloud" ]

packages.each do |pkg|
  package pkg do
    action :install
  end
end

