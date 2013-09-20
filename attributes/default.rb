#
# Cookbook Name:: zwift
# Attributes:: default
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

free_memory = node["memory"]["free"].to_i

# common
default["zwift"]["common"]["ssh_user"] = "swiftops"
default["zwift"]["common"]["ssh_key"] = "/tmp/id_rsa_swiftops.priv"
default["zwift"]["common"]["swift_generic"] = "swift python-swift python-swiftclient"
default["zwift"]["common"]["swift_proxy"] =
  "swift-proxy python-keystone python-keystoneclient memcached python-memcache"
default["zwift"]["common"]["swift_storage"] = "swift-account swift-container swift-object"
default["zwift"]["common"]["swift_others"] = "python-suds"

if platform_family?("debian")
  default["zwift"]["common"]["pkg_options"] =
    "-y -qq --force-yes -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold"
else
  default["zwift"]["common"]["pkg_options"] = ""
end

if platform?("centos")
  default["zwift"]["common"]["pkg_holds"] = [
    "openstack-swift", "python-swiftclient", "openstack-swift-account",
    "openstack-swift-container", "openstack-swift-object",
    "openstack-swift-proxy", "python-keystoneclient", "python-memcached",
    "python-keystone", "rsync", "memcached"]
elsif platform?("ubuntu")
  default["zwift"]["common"]["pkg_holds"] = [
    "swift", "python-swiftclient", "swift-account",
    "swift-container", "swift-object",
    "swift-proxy", "python-keystoneclient", "python-memcached",
    "python-keystone", "rsync", "memcached"]
else
  default["zwift"]["common"]["pkg_holds"] = []
end

# network
#default["zwift"]["network"]["management"] = "cidr"
#default["zwift"]["network"]["exnet"] = "cidr"

# swift_common
default["zwift"]["swift_common"]["swift_hash_prefix"] = nil
default["zwift"]["swift_common"]["swift_hash_suffix"] = nil
default["zwift"]["swift_common"]["admin_ip"] = nil
default["zwift"]["swift_common"]["syslog_ip"] = nil

# common statsd config -- these will be merged into configs unless overridden in the specific
# object/container/etc tunings
default["zwift"]["swift_common"]["log_statsd_host"] = nil
default["zwift"]["swift_common"]["log_statsd_port"] = 8125
default["zwift"]["swift_common"]["log_statsd_default_sample_rate"] = 1.0
default["zwift"]["swift_common"]["log_statsd_sample_rate_factor"] = 1.0
default["zwift"]["swift_common"]["log_statsd_metric_prefix"] = nil

# object server tuning

# Note that any object-server config can be represented here, but these are the
# knobs most frequently frobbed.
default["zwift"]["object"]["config"]["DEFAULT"]["workers"] = 8
default["zwift"]["object"]["config"]["DEFAULT"]["backlog"] = 4096
default["zwift"]["object"]["config"]["DEFAULT"]["disable_fallocate"] = false
default["zwift"]["object"]["config"]["DEFAULT"]["fallocate_reserve"] = 0

default["zwift"]["object"]["config"]["app:object-server"]["node_timeout"] = 3
default["zwift"]["object"]["config"]["app:object-server"]["conn_timeout"] = 0.5

default["zwift"]["object"]["config"]["object-replicator"]["run_pause"] = 30
default["zwift"]["object"]["config"]["object-replicator"]["concurrency"] = 6
default["zwift"]["object"]["config"]["object-replicator"]["rsync_timeout"] = 900
default["zwift"]["object"]["config"]["object-replicator"]["rsync_io_timeout"] = 30
default["zwift"]["object"]["config"]["object-replicator"]["http_timeout"] = 60
default["zwift"]["object"]["config"]["object-replicator"]["lockup_timeout"] = 1800

default["zwift"]["object"]["config"]["object-updater"]["concurrency"] = 3
default["zwift"]["object"]["config"]["object-updater"]["node_timeout"] = 60
default["zwift"]["object"]["config"]["object-updater"]["conn_timeout"] = 5
default["zwift"]["object"]["config"]["object-updater"]["slowdown"] = 0.01

# container tuning -- note that any container-server config can be represented here
default["zwift"]["container"]["config"]["DEFAULT"]["backlog"] = "4096"
default["zwift"]["container"]["config"]["DEFAULT"]["workers"] = "6"
default["zwift"]["container"]["config"]["DEFAULT"]["disable_fallocate"] = "false"
default["zwift"]["container"]["config"]["DEFAULT"]["db_preallocation"] = "off"
default["zwift"]["container"]["config"]["DEFAULT"]["fallocate_reserve"] = 0

default["zwift"]["container"]["config"]["app:container-server"]["node_timeout"] = 3
default["zwift"]["container"]["config"]["app:container-server"]["conn_timeout"] = 0.5
default["zwift"]["container"]["config"]["app:container-server"]["allow_versions"] = "false"

default["zwift"]["container"]["config"]["container-replicator"]["per_diff"] = 1000
default["zwift"]["container"]["config"]["container-replicator"]["max_diffs"] = 100
default["zwift"]["container"]["config"]["container-replicator"]["concurrency"] = 6
default["zwift"]["container"]["config"]["container-replicator"]["interval"] = 30
default["zwift"]["container"]["config"]["container-replicator"]["node_timeout"] = 15
default["zwift"]["container"]["config"]["container-replicator"]["conn_timeout"] = 0.5
default["zwift"]["container"]["config"]["container-replicator"]["reclaim_age"] = 604800

default["zwift"]["container"]["config"]["container-updater"]["interval"] = 300
default["zwift"]["container"]["config"]["container-updater"]["concurrency"] = 4
default["zwift"]["container"]["config"]["container-updater"]["node_timeout"] = 15
default["zwift"]["container"]["config"]["container-updater"]["conn_timeout"] = 5
default["zwift"]["container"]["config"]["container-updater"]["account_suppression_time"] = 60

default["zwift"]["container"]["config"]["container-auditor"]["interval"] = 1800
default["zwift"]["container"]["config"]["container-auditor"]["containers_per_second"] = 200

# account tuning -- note that any account-server config can be represented here
default["zwift"]["account"]["config"]["DEFAULT"]["backlog"] = 4096
default["zwift"]["account"]["config"]["DEFAULT"]["workers"] = 6
default["zwift"]["account"]["config"]["DEFAULT"]["disable_fallocate"] = false
default["zwift"]["account"]["config"]["DEFAULT"]["db_preallocation"] = "off"
default["zwift"]["account"]["config"]["DEFAULT"]["fallocate_reserve"] = 0

default["zwift"]["account"]["config"]["account-replicator"]["per_diff"] = 10000
default["zwift"]["account"]["config"]["account-replicator"]["max_diffs"] = 100
default["zwift"]["account"]["config"]["account-replicator"]["concurrency"] = 4
default["zwift"]["account"]["config"]["account-replicator"]["interval"] = 30
default["zwift"]["account"]["config"]["account-replicator"]["error_suppression_interval"] = 60
default["zwift"]["account"]["config"]["account-replicator"]["error_suppression_limit"] = 10
default["zwift"]["account"]["config"]["account-replicator"]["node_timeout"] = 10
default["zwift"]["account"]["config"]["account-replicator"]["conn_timeout"] = 0.5
default["zwift"]["account"]["config"]["account-replicator"]["reclaim_age"] = 604800
default["zwift"]["account"]["config"]["account-replicator"]["run_pause"] = 30

default["zwift"]["account"]["config"]["account-auditor"]["interval"] = 1800
default["zwift"]["account"]["config"]["account-auditor"]["accounts_per_second"] = 100

default["zwift"]["account"]["config"]["account-reaper"]["concurrency"] = 2
default["zwift"]["account"]["config"]["account-reaper"]["interval"] = 3600
default["zwift"]["account"]["config"]["account-reaper"]["node_timeout"] = 10
default["zwift"]["account"]["config"]["account-reaper"]["conn_timeout"] = 0.5
default["zwift"]["account"]["config"]["account-reaper"]["delay_reaping"] = 604800

# Proxy tuning -- note that any proxy-server config can be represented here
default["zwift"]["proxy"]["config"]["DEFAULT"]["backlog"] = 4096
default["zwift"]["proxy"]["config"]["DEFAULT"]["workers"] = 12

default["zwift"]["proxy"]["config"]["pipeline:main"]["pipeline"] = "catch_errors proxy-logging healthcheck cache ratelimit proxy-logging proxy-query proxy-server"

default["zwift"]["proxy"]["config"]["app:proxy-server"]["node_timeout"] = 60
default["zwift"]["proxy"]["config"]["app:proxy-server"]["client_timeout"] = 60
default["zwift"]["proxy"]["config"]["app:proxy-server"]["conn_timeout"] = 3.5
default["zwift"]["proxy"]["config"]["app:proxy-server"]["error_suppression_interval"] = 60
default["zwift"]["proxy"]["config"]["app:proxy-server"]["error_suppression_limit"] = 10
default["zwift"]["proxy"]["config"]["app:proxy-server"]["object_post_as_copy"] = true

# rsync tuning
default["zwift"]["rsync"]["config"]["account"]["max connections"] = 8
default["zwift"]["rsync"]["config"]["container"]["max connections"] = 12
default["zwift"]["rsync"]["config"]["object"]["max connections"] = 18

# drive_audit
regex_patterns = [
  "\\berror\\b.*\\b(sd[a-z]{1,2}\\d?)\\b",
  "\\b(sd[a-z]{1,2}\d?)\\b.*\\berror\\b"]

default["zwift"]["drive_audit"]["minutes"] = 5
default["zwift"]["drive_audit"]["log_file_pattern"] = "/var/log/kern*"
default["zwift"]["drive_audit"]["regex_patterns"] = regex_patterns

# proxy
default["zwift"]["proxy"]["memcache_maxmem"] = 512
default["zwift"]["proxy"]["sim_connections"] = 1024
default["zwift"]["proxy"]["memcache_server_list"] = "127.0.0.1:11211"
default["zwift"]["proxy"]["authtoken_factory"] = "keystoneclient.middleware.auth_token:filter_factory"
default["zwift"]["proxy"]["sysctl"] = {
  "net.ipv4.tcp_tw_recycle" => "1",
  "net.ipv4.tcp_tw_reuse" => "1",
  "net.ipv4.ip_local_port_range" => "1024 61000",
  "net.ipv4.tcp_syncookies" => 0
}

# storage
default["zwift"]["storage"]["sysctl"] = {
  "net.ipv4.tcp_tw_recycle" => "1",
  "net.ipv4.tcp_tw_reuse" => "1",
  "net.ipv4.ip_local_port_range" => "1024 61000",
  "net.ipv4.tcp_syncookies" => "0",
  "vm.min_free_kbytes" => (free_memory/2 > 1048576) ? 1048576 : (free_memory/2).to_i
}

# mailing
default["zwift"]["mailing"]["email_addr"] = "me@mydomain.com"
default["zwift"]["mailing"]["pager_addr"] = "mepager@mydomain.com"
default["zwift"]["mailing"]["smarthost"] = nil
default["zwift"]["mailing"]["relay_nets"] = nil  # array of cidr for relays
default["zwift"]["mailing"]["outgoing_domain"] = "swift.mydomain.com"

# versioning
default["zwift"]["versioning"]["versioning_system"] = "git"
default["zwift"]["versioning"]["repository_base"] = "/srv/git"
default["zwift"]["versioning"]["repository_name"] = "rings"
#default["zwift"]["versioning"]["repository_host"] = "ip/hostname"

# keystone
default["zwift"]["keystone"]["region"] = "RegionOne"
#default["zwift"]["keystone"]["swift_admin_url"] = http://ip:port/v1/AUTH_%(tenant_id)s"
#default["zwift"]["keystone"]["swift_internal_url"] = ...
#default["zwift"]["keystone"]["swift_public_url"] = ...
#default["zwift"]["keystone"]["keystone_admin_url"] = http://ip:port/v2.0
#default["zwift"]["keystone"]["keystone_internal_url"] = ...
#default["zwift"]["keystone"]["keystone_public_url"] = ...

default["zwift"]["keystone"]["ops_user"] = "swiftops"
default["zwift"]["keystone"]["ops_tenant"] = "swiftops"

default["zwift"]["keystone"]["auth_user"] = "swift"
default["zwift"]["keystone"]["auth_tenant"] = "service"
#default["zwift"]["keystone"]["auth_password"] = "<pw>"
default["zwift"]["keystone"]["admin_user"] = "admin"
#default["zwift"]["keystone"]["admin_password"] = "<pw>"
default["zwift"]["keystone"]["pki"] = false

# default["zwift"]["keystone"]["auth_uri"] = "http://172.16.0.252:5000/v2.0"
# default["zwift"]["keystone"]["keystone_admin_tenant"] = "service"
# default["zwift"]["keystone"]["keystone_admin_user"] = "tokenvalidator"
# default["zwift"]["keystone"]["keystone_admin_password"] = "noswifthere"

# dispersion
default["zwift"]["dispersion"]["dis_tenant"] = "dispersion"
default["zwift"]["dispersion"]["dis_user"] = "reporter"
#default["zwift"]["dispersion"]["dis_key"] = "<pw>"
default["zwift"]["dispersion"]["dis_coverage"] = "1"

# exim
if platform_family?("rhel")
  default["exim"]["platform"] = {
    "packages" => ["exim"],
    "service" => "exim",
    "removes" => ["postfix"]
  }
elsif platform_family?("debian")
  default["exim"]["platform"] = {
    "packages" => ["exim4"],
    "service" => "exim4",
    "removes" => ["postfix"]
  }
end

# snmp
if platform_family?("rhel")
  default["snmp"]["platform"] = {
    "packages" => ["net-snmp", "net-snmp-utils"],
    "service" => "snmpd"
  }
elsif platform_family?("debian")
  default["snmp"]["platform"] = {
    "packages" => ["snmp", "snmpd"],
    "service" => "snmpd"
  }
end

# syslog-ng
if platform_family?("rhel")
  default["syslog-ng"]["platform"] = {
    "packages" => ["syslog-ng", "syslog-ng-libdbi"],
    "service" => "syslog-ng",
    "replaces" => ["rsyslog", "syslog"]
  }
elsif platform_family?("debian")
  default["syslog-ng"]["platform"] = {
    "packages" => ["syslog-ng"],
    "service" => "syslog-ng",
    "replaces" => ["rsyslog"]
  }
end
