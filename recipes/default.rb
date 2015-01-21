include_recipe "eol-docker::docker"

env = node.environment
Chef::Environment = env

return unless data_bag("eol-docker").include?(env)

conf = data_bag_item("eol-docker", env)[node.ipaddress]

passwords = nil
secret = "/etc/chef/data_bag_secret_key"
if File.exist?(secret)
  secret = Chef::EncryptedDataBagItem.load_secret(secret)
  passwords = Chef::EncryptedDataBagItem.
    load("eol-docker", "#{env}_passwords", secret)
end

return unless conf

directory "/eol" do
  user "root"
  group "root"
  mode "0755"
end

conf["containers"].each do |c|
  docker_container c["name"] do
    config c
    passwd passwords
  end
end
