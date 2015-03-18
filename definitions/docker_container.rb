define :docker_container, config: nil do

  conf = params[:config]
  params = conf["params"]
  shared_files = []
  shared_ports = []
  env_files = []
  passwords = nil

  directory "/eol/#{conf["name"]}" do
    user "root"
    group "docker"
    mode "0775"
  end

  ef = conf["env_files"]
  if ef
    ef.each do |env_file|
      env_files << env_file
    end
  end

  cf = conf["config_files"]
  if cf
    cf.each do |f|
      directory File.dirname(f["host"]) do
        recursive true
        user "root"
        group "docker"
        mode "775"
      end
      template f["host"] do
        user "root"
        group "docker"
        mode "664"
        source f["template"]
        variables params: params
        action :create
      end
      shared_files << [f["host"],f["container"]]
    end
  end

  ddirs = conf["data_dirs"]
  if ddirs
    ddirs.each do |ddr|
      dir = ddr["host"]
      dir = File.directory(dir) if dir =~ /\.[a-z]{2,4}$/
      directory dir do
        recursive true
        user "root"
        group "docker"
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
      variables params: params,
                name: conf["name"],
                env_files: env_files,
                shared_files: shared_files,
                shared_ports: shared_ports
      mode "775"
      user "root"
      group "docker"
    end
  end

  execute "/usr/local/bin/#{conf['name']}_restart" do
    user "root"
    not_if "/usr/bin/docker ps | grep #{conf['name']}"
  end
end
