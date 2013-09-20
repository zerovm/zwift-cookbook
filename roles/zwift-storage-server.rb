name "zwift-storage-server"
description "storage node for zwift"
run_list(
  "recipe[osops-utils::packages]",
  "recipe[swift-lite::account-server]",
  "recipe[swift-lite::container-server]",
  "recipe[zwift::object-server]"
)
