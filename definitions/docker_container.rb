define :docker_container, config: nil, passwd: nil do

  conf = params[:config]
  params = conf["params"]
  shared_files = []
  shared_ports = []
  passwords = nil

  directory "/eol/#{conf["name"]}" do
    user "root"
    group "root"
    mode "0775"
  end

  cf = conf["config_files"]
  if cf
    cf.each do |f|
      directory File.dirname(f["host"]) do
        recursive true
        user "root"
        group "root"
        mode "775"
      end
      template f["host"] do
        user "root"
        group "root"
        source f["template"]
        variables params: params
      end
      shared_files << [f["host"],f["container"]]
    end
  end

  ddirs = conf["data_dirs"]
  if ddirs
    ddirs.each do |ddr|
      directory File.dirname(ddr["host"]) do
        recursive true
        user "root"
        group "root"
        mode "775"
      end
      shared_files << [ddr["host"], ddr["container"]]
    end
  end

  ports = conf["ports"]
  if ports
    ports.each do |port|
      shared_ports << [port["host"], port["container"]]
    end
  end

  sf = conf["service_files"]
  %w(start stop restart).each do |actn|
    file_name = "#{conf['name']}_#{actn}"
    template "/usr/local/bin/#{file_name}" do
      source sf[actn + "_template"]
      variables params: params, name: conf["name"],
                shared_files: shared_files, shared_ports: shared_ports
      mode "775"
      user "root"
      group "root"
    end
  end

  execute "/usr/local/bin/#{conf['name']}_start" do
    user "root"
    not_if "/usr/bin/docker ps | grep #{conf['name']}"
  end
end
