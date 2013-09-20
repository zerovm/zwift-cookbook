name "zwift-proxy-server"
description "proxy node for zwift"
run_list(
  "recipe[osops-utils::packages]",
  "recipe[zwift::proxy-server]"
)
