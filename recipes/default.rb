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

directory "/eol/shared" do
  user "root"
  group "docker"
  mode "0775"
  recursive true
end

file "/eol/shared/containers" do
  content node_conf["containers"].map { |c| c["name"] }.join("\n")
  owner "root"
  group "docker"
  mode 00644
end

names = []
node_conf["containers"].each do |c|
  names << c["name"]
  docker_container c["name"] do
    config c
  end
end

%w(docker_clean docker_nuke docker_names).each do |f|
  cookbook_file f do
    path "/usr/local/bin/#{f}"
    mode "0755"
    action :create
  end
end

template "/usr/local/bin/restart_all" do
  source "restart_all.erb"
  variables names: names
  mode "775"
  user "root"
  group "docker"
end
