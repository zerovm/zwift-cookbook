#
# Cookbook Name:: zwift
# Recipe:: object-server
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

include_recipe "zwift::common"
include_recipe "swift-lite::object-server"

common = node["zwift"]["swift_common"]


# For more configurable options and information please check either object-server.conf manpage
# or object-server.conf-sample provided within the distributed package 
default_options = {
  "DEFAULT" => {
    "bind_ip" => "0.0.0.0",
    "bind_port" => "6000",
    "backlog" => "4096",
    "workers" => "8",
    "disable_fallocate" => "false",
    "fallocate_reserve" => "0",
    "user" => "swift",
    "devices" => "/srv/node",
    "swift_dir" => "/etc/swift"
  },
  "pipeline:main" => {
    "pipeline" => "healthcheck recon object-query object-server"
  },
  "app:object-server" => {
    "use" => "egg:swift#object",
    "log_facility" => "LOG_LOCAL1",
    "mb_per_sync" => "64"
  },
  "filter:healthcheck" => {
    "use" => "egg:swift#healthcheck"
  },
  "filter:recon" => {
    "use" => "egg:swift#recon",
    "log_facility" => "LOG_LOCAL2",
    "recon_cache_path" => "/var/cache/swift",
    "recon_lock_path" => "/var/lock/swift"
  },
  "filter:object-query" => {
    "use" => "egg:zerocloud#object_query",
    "zerovm_timeout" => "360",
    "zerovm_maxpool" => "10",
    "zerovm_maxinput" => "5368709120",
    "zerovm_maxoutput" => "5368709120"
  },
  "object-replicator" => {
    "log_facility" => "LOG_LOCAL2",
    "concurrency" => "6",
    "rsync_io_timeout" => "30",
    "recon_enable" => "yes",
    "recon_cache_path" => "/var/cache/swift"
  },
  "object-updater" => {
    "log_facility" => "LOG_LOCAL2",
    "concurrency" => "3",
    "node_timeout" => "60",
    "conn_timeout" => "5",
    "recon_enable" => "yes",
    "recon_cache_path" => "/var/cache/swift"
  },
  "object-auditor" => {
    "log_facility" => "LOG_LOCAL2",
    "recon_enable" => "yes",
    "recon_cache_path" => "/var/cache/swift"
  }
}

overrides = { "DEFAULT" => node["zwift"]["swift_common"].select { |k, _| k.start_with?("log_statsd_") }}

if node["zwift"]["object"] and node["zwift"]["object"]["config"]
  overrides = overrides.merge(node["zwift"]["object"]["config"]) { |k, x, y| x.merge(y) }
end

resources("template[/etc/swift/object-server.conf]").instance_exec do
  cookbook "zwift"
  source "inifile.conf.erb"
  mode "0644"
  variables("config_options" => default_options.merge(overrides) { |k, x, y| x.merge(y) })
end

packages = [ "python-zerocloud" , "zerovm" ]

packages.each do |pkg|
  package pkg do
    action :install
  end
end

