define :docker_container, config: nil, passwd: nil do

  conf = params[:config]
  params = conf["params"]
  passwrords = nil

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
    end
  end

  sf = conf["service_files"]
  %w(start_template stop_template restart_template).each do |f|
    template "/usr/local/bin/#{sf[f]}" do
      source sf[f] + ".erb"
      variables params: params, name: conf["name"]
      mode "755"
      user "root"
      group "root"
    end
  end

  execute "/usr/local/bin/#{conf['name']}_start" do
    user "root"
    not_if "/usr/bin/docker ps | grep #{conf['name']}"
  end
end
