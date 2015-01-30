include_recipe "eol-docker::docker"

env = node.environment

return unless data_bag("eol-docker").include?(env)

dbag = data_bag_item("eol-docker", env)
node_conf = dbag[node.name]

log "node_conf: %s" % node_conf

group "docker" do
  members dbag["docker_members"]
end

return unless node_conf

directory "/eol" do
  user "root"
  group "docker"
  mode "0775"
end

names = []
node_conf["containers"].each do |c|
  names << c["name"]
  docker_container c["name"] do
    config c
  end
end

template "/usr/local/bin/restart_all" do
  source "restart_all.erb"
  variables names: names
  mode "775"
  user "root"
  group "docker"
end
