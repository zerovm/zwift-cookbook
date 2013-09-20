#
# Cookbook Name:: zwift
# Recipe:: common
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
include_recipe "zwift::packages"
#include_recipe "swift-lite::ntp"
include_recipe "swift-lite::common"
include_recipe "git"


resources("directory[/etc/swift]").mode "0755"
resources("template[/etc/swift/swift.conf]").mode "0644"

# make sure we have a swift lock directory - should this be in swift-lite?
directory "/var/lock/swift" do
  owner "swift"
  group "swift"
  mode "0750"
  action :create
end
