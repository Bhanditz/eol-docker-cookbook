def install_ubuntu
  require "apt"
  apt_repository "docker" do
    uri "https://get.docker.com/ubuntu"
    distribution node["lsb"]["codename"]
    components["main"]
    keyserver "keyserver.ubuntu.com"
    key "36A1D7869245C8950F966E92D8576A8BA88D21E9"
  end
  package "lxc-docker"
end

def install_rhel
  inlude_recipe "yum-epel"
  package "docker-io"
end

if platform?("ubuntu")
  install_ubuntu
elsif platform?("redhat", "centos")
  install_rhel
else
  raise("#{node["platform"]} is not supported")
end
