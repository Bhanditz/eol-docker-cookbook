eol-docker Cookbook
===================

This cookbook installs docker and creates EOL infrastructure according to
eol-docker/infrastructure data bag. The cookbook reads from eol-docker data
bags which containers need to be installed on which node. It also creates
start/stop/restart scripts, and these scripts designate where to read
configuration files, which directories to make available inside of the
container, which environment variables need to be set.

Requirements
------------

#### cookbooks
- `apt`, 'yum' - eol-docker uses either apt-get or yum to install docker on the
                 host Linux machine


Usage
-----
#### eol-docker::default

Create production and/or staging environment on chef server, change
`chef_environment` setting from  `_default` to a corresponding environment for
every node that is part of your infrastructure.

```bash
$ knife environment create production
$ knife node edit server.example.org
```

Create data bag that describes your infrastructure for production or staging
environments

```bash
$ knife data bag create eol-docker
$ knife data bag create eol-docker production
```
Make sure that nodes have correct `chef_environment` value. No changes will be
made to a node if environment value does not correspond to the name of the data
bag item (if data bag item is called production -- participating nodes should
have `production` as their `chef_environment`. In examples below we assume 
a `production` environment.

Include `eol-docker` in your node's, or role's `run_list`, or include recipe to
your cookbook:

```json
{
  "name": "server.example.org",
  "chef_environment": "production",
  "run_list": [
    "recipe[eol-docker]"
  ]
}
```
### eol-docker databag

Assuming you are creating a production environment this is an expected 
structure of the `production` item.

#### General parameters:

Parameter                   | Description
----------------------------|---------------------------------------------------
`id`                        | Defines environment of the system
`eol_env_path`              | File with eol settings for database, solr etc.
`eol_env_newrelic_pro_path` | File with production newrelic key
`docker_members`            | Users who are able to run docker without sudo
`containers`                | Array for each node with container desciptions

#### Container parameters

Parameter      | Description
---------------|------------------------------------------------------------
`name`         | Name of the container
`service_files`| Templates to generate start/stop/restart container scripts
`ports`        | Ports mapping between container and host
`volumes`      | Directory mapping between container and host
`env_files`    | Path to file with container's environment variables
`params`       | Miscellaneous parameters for container


#### Example of a production eol infrastructure

```json
{
  "id": "production",
  "eol_env_path": "/eol/config/production.env",
  "eol_env_newrelic_pro_path": "/eol/config/newrelic_pro.env",
  "docker_members": [
    "user1",
    "user2",
    "sensu",
  ],
  "eol-harvest1.example.org": {
    "containers": [
      {
        "name": "harvest",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 80,
            "container": 80
          }
        ],
        "volumes": [
          {
            "host": "/eol/config/database.php.yml",
            "container": "/var/www/eol_php_code/config/database.yml",
            "user": "www-data",
            "group": "www-data"
          },
          {
            "host": "/eol/config/production.php",
            "container": "/var/www/eol_php_code/config/environments/production.php",
            "user": "www-data",
            "group": "www-data"
          },
          {
            "host": "/eol/data/harvest/log",
            "container": "/var/www/eol_php_code/log",
            "user": "www-data",
            "group": "www-data"
          },
          {
            "host": "/eol/data/var/log/nginx",
            "container": "/var/log/nginx",
            "user": "www-data",
            "group": "www-data"
          },
          {
            "host": "/eol/data/var/www/downloads",
            "container": "/var/www/downloads",
            "user": "www-data",
            "group": "www-data"
          },
          {
            "host": "/eol/data/var/www/content",
            "container": "/var/www/content",
            "user": "www-data",
            "group": "www-data"
          },
          {
            "host": "/eol/data/var/www/resources",
            "container": "/var/www/resources",
            "user": "www-data",
            "group": "www-data"
          }
        ],
        "env_files": [
          "/eol/config/production.env"
        ],
        "params": {
          "version": "latest",
          "image": "encoflife/harvest",
          "harvest_server_name": "services2.eol.org"
        }
      },
      {
        "name": "app7",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 8081,
            "container": 80
          }
        ],
        "env_files": [
          "/eol/config/production.env"
        ],
        "volumes": [
          {
            "host": "/eol/data/app/log/app7",
            "container": "/app/log"
          }
        ],
        "params": {
          "version": "latest",
          "image": "encoflife/eol"
        }
      }
    ]
  },
  "eol1.example.org": {
    "containers": [
      {
        "name": "varnish",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 80,
            "container": 80
          }
        ],
        "config_files": [
          {
            "host": "/eol/config/varnish/etc/varnish/default.vcl",
            "container": "/etc/varnish/default.vcl",
            "template": "varnish_default.vcl.erb"
          }
        ],
        "params": {
          "version": "latest",
          "image": "encoflife/varnish",
          "content_host": "50.50.50.50",
          "content_ip": "10.0.0.22",
          "content_port": 8080,
          "sysopia_host": "sysopia.example.org",
          "sysopia_ip": "10.0.0.3",
          "sysopia_port": "9999",
          "sensu_host": "sense.example.org",
          "sensu_ip": "10.0.0.4",
          "sensu_port": "3000",
          "harvest_host": "services.example.org",
          "harvest_ip": "10.0.0.0.5",
          "harvest_port": "80",
          "apps": [
            {
              "name": "1",
              "ip": "10.0.0.6",
              "port": 8081,
              "director": "appfarm"
            },
            {
              "name": "2",
              "ip": "10.0.0.6",
              "port": 8082,
              "director": "searchbots"
            },
            {
              "name": "3",
              "ip": "10.0.0.6",
              "port": 8083,
              "director": "apirequests"
            },
            {
              "name": "4",
              "ip": "10.0.0.7",
              "port": 8081,
              "director": "appfarm"
            },
            {
              "name": "5",
              "ip": "10.0.0.7",
              "port": 8082,
              "director": "searchbots"
            },
            {
              "name": "6",
              "ip": "10.0.0.7",
              "port": 8083,
              "director": "apirequests"
            }
          ]
        }
      },
      {
        "name": "memcached",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 11211,
            "container": 11211
          }
        ],
        "params": {
          "version": "latest",
          "image": "encoflife/memcached"
        }
      },
      {
        "name": "content",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 8080,
            "container": 80
          }
        ],
        "volumes": [
          {
            "host": "/eol/data",
            "container": "/usr/share/nginx/html:ro"
          }
        ],
        "params": {
          "version": "latest",
          "image": "nginx"
        }
      }
    ]
  },
  "eol2.example.org": {
    "containers": [
      {
        "name": "haproxy",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 3306,
            "container": 3306
          }
        ],
        "config_files": [
          {
            "host": "/eol/config/haproxy/haproxy.cfg",
            "container": "/usr/local/etc/haproxy/haproxy.cfg",
            "template": "haproxy.cfg.erb"
          }
        ],
        "params": {
          "version": "latest",
          "image": "haproxy",
          "slaves": [
            {"name": "eol-db-slave1", "ip": "10.0.0.8"}
          ]
        }
      },
      {
        "name": "memcached",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 11211,
            "container": 11211
          }
        ],
        "params": {
          "version": "latest",
          "image": "encoflife/memcached"
        }
      }
    ]
  },
  "eol-search1.example.org": {
    "containers": [
      {
        "name": "solr",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 8983,
            "container": 8983
          }
        ],
        "config_files": [
          {
            "host": "/eol/config/solr/opt/solr/example/etc/jetty.xml",
            "container": "/opt/solr/example/etc/jetty.xml",
            "template": "jetty.xml.erb"
          }
        ],
        "volumes": [
          {
            "host": "/eol/data/solr/var/lib/solr",
            "container": "/opt/solr/example/data"
          }
        ],
        "params": {
          "version": "3.3.0",
          "image": "encoflife/solr",
          "header_size": "8192"
        }
      }
    ]
  },
  "eol-traitbank1.example.org": {
    "containers": [
      {
        "name": "virtuoso",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 1111,
            "container": 1111
          },
          {
            "host": 8890,
            "container": 8890
          }
        ],
        "config_files": [
          {
            "host": "/eol/config/virtuoso/var/lib/virtuoso/db/virtuoso.ini",
            "container": "/usr/local/var/lib/virtuoso/db/virtuoso.ini",
            "template": "virtuoso.ini.erb"
          }
        ],
        "volumes": [
          {
            "host": "/eol/data/virtuoso/var/lib/virtuoso/db",
            "container": "/usr/local/var/lib/virtuoso/db"
          },
          {
            "host": "/eol/data/virtuoso/var/log/virtuoso-http",
            "container": "/var/log/virtuoso-http"
          }
        ],
        "params": {
          "version": "7.1.0",
          "image": "encoflife/virtuoso",
          "number_of_buffers": 10900000,
          "max_dirty_buffers": 8000000
        }
      }
    ]
  },
  "eol-db-master1.example.org": {
    "containers": [
      {
        "name": "db_master",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop_mysql.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 3306,
            "container": 3306
          }
        ],
        "config_files": [
          {
            "host": "/eol/config/db_master/etc/mysql/my.cnf",
            "container": "/etc/mysql/my.cnf",
            "template": "my.cnf.erb"
          }
        ],
        "volumes": [
          {
            "host": "/eol/data/db_master/var/lib/mysql",
            "container": "/var/lib/mysql",
            "user": "mysql",
            "group": "mysql"
          },
          {
            "host": "/eol/data/db_master/var/log/mysql",
            "container": "/var/log/mysql",
            "user": "mysql",
            "group": "mysql"
          }
        ],
        "env_files": [
          "/eol/config/production.env"
        ],
        "params": {
          "version": "5.1",
          "image": "encoflife/mysql",
          "binlog": "true",
          "server_id": "1",
          "innodb_buffer_pool_size": "55G"
        }
      }
    ]
  },
  "eol-db-slave1.example.org": {
    "containers": [
      {
        "name": "db_slave1",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop_mysql.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 3306,
            "container": 3306
          }
        ],
        "config_files": [
          {
            "host": "/eol/config/db_slave1/etc/mysql/my.cnf",
            "container": "/etc/mysql/my.cnf",
            "template": "my.cnf.erb"
          }
        ],
        "volumes": [
          {
            "host": "/eol/data/db_slave1/var/lib/mysql",
            "container": "/var/lib/mysql",
            "user": "mysql",
            "group": "mysql"
          },
          {
            "host": "/eol/data/db_slave1/var/log/mysql",
            "container": "/var/log/mysql",
            "user": "mysql",
            "group": "mysql"
          }
        ],
        "env_files": [
          "/eol/config/production.env",
          "/eol/config/db_slave.env"
        ],
        "params": {
          "version": "5.1",
          "image": "encoflife/mysql",
          "replication_slave": "true",
          "binlog": "true",
          "server_id": "2",
          "innodb_buffer_pool_size": "55G"
        }
      }
    ]
  },
  "eol-db-slave2.example.org": {
    "containers": [
      {
        "name": "db_slave2",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop_mysql.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 3306,
            "container": 3306
          }
        ],
        "config_files": [
          {
            "host": "/eol/config/db_slave2/etc/mysql/my.cnf",
            "container": "/etc/mysql/my.cnf",
            "template": "my.cnf.erb"
          }
        ],
        "volumes": [
          {
            "host": "/eol/data/db_slave2/var/lib/mysql",
            "container": "/var/lib/mysql",
            "user": "mysql",
            "group": "mysql"
          },
          {
            "host": "/eol/data/db_slave2/var/log/mysql",
            "container": "/var/log/mysql",
            "user": "mysql",
            "group": "mysql"
          }
        ],
        "env_files": [
          "/eol/config/production.env",
          "/eol/config/db_slave.env"
        ],
        "params": {
          "version": "5.1",
          "image": "encoflife/mysql",
          "replication_slave": "true",
          "binlog": "true",
          "server_id": "3",
          "innodb_buffer_pool_size": "55G"
        }
      }
    ]
  },
  "eol-db-slave3.example.org": {
    "containers": [
      {
        "name": "db_slave3",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop_mysql.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 3306,
            "container": 3306
          }
        ],
        "config_files": [
          {
            "host": "/eol/config/db_slave3/etc/mysql/my.cnf",
            "container": "/etc/mysql/my.cnf",
            "template": "my.cnf.erb"
          }
        ],
        "volumes": [
          {
            "host": "/eol/data/db_slave3/var/lib/mysql",
            "container": "/var/lib/mysql",
            "user": "mysql",
            "group": "mysql"
          },
          {
            "host": "/eol/data/db_slave3/var/log/mysql",
            "container": "/var/log/mysql",
            "user": "mysql",
            "group": "mysql"
          }
        ],
        "env_files": [
          "/eol/config/production.env"
        ],
        "params": {
          "version": "5.1",
          "image": "encoflife/mysql",
          "replication_slave": "true",
          "binlog": "true",
          "server_id": "4",
          "innodb_buffer_pool_size": "55G"
        }
      }
    ]
  },
  "eol-app1.example.org": {
    "containers": [
      {
        "name": "app1",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 8081,
            "container": 80
          }
        ],
        "env_files": [
          "/eol/config/production.env",
          "/eol/config/newrelic_pro.env"
        ],
        "volumes": [
          {
            "host": "/eol/data/app/log/app1",
            "container": "/app/log"
          }
        ],
        "params": {
          "version": "latest",
          "image": "encoflife/eol"
        }
      },
      {
        "name": "app2",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 8082,
            "container": 80
          }
        ],
        "env_files": [
          "/eol/config/production.env"
        ],
        "volumes": [
          {
            "host": "/eol/data/app/log/app2",
            "container": "/app/log"
          }
        ],
        "params": {
          "version": "latest",
          "image": "encoflife/eol"
        }
      },
      {
        "name": "app3",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 8083,
            "container": 80
          }
        ],
        "env_files": [
          "/eol/config/production.env"
        ],
        "volumes": [
          {
            "host": "/eol/data/app/log/app3",
            "container": "/app/log"
          }
        ],
        "params": {
          "version": "latest",
          "image": "encoflife/eol"
        }
      }
    ]
  },
  "eol-app2.example.org": {
    "containers": [
      {
        "name": "app4",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 8081,
            "container": 80
          }
        ],
        "env_files": [
          "/eol/config/production.env"
        ],
        "volumes": [
          {
            "host": "/eol/data/app/log/app4",
            "container": "/app/log"
          }
        ],
        "params": {
          "version": "latest",
          "image": "encoflife/eol"
        }
      },
      {
        "name": "app5",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 8082,
            "container": 80
          }
        ],
        "env_files": [
          "/eol/config/production.env"
        ],
        "volumes": [
          {
            "host": "/eol/data/app/log/app5",
            "container": "/app/log"
          }
        ],
        "params": {
          "version": "latest",
          "image": "encoflife/eol"
        }
      },
      {
        "name": "app6",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 8083,
            "container": 80
          }
        ],
        "env_files": [
          "/eol/config/production.env"
        ],
        "volumes": [
          {
            "host": "/eol/data/app/log/app6",
            "container": "/app/log"
          }
        ],
        "params": {
          "version": "latest",
          "image": "encoflife/eol"
        }
      }
    ]
  },
  "eol-tools1.example.org": {
    "containers": [
      {
        "name": "db_sysopia",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop_mysql.erb",
          "restart_template": "restart.erb"
        },
        "ports": [
          {
            "host": 3306,
            "container": 3306
          }
        ],
        "config_files": [
          {
            "host": "/eol/config/db_sysopia/etc/mysql/my.cnf",
            "container": "/etc/mysql/my.cnf",
            "template": "my.cnf.erb"
          }
        ],
        "volumes": [
          {
            "host": "/eol/data/db_sysopia/var/lib/mysql",
            "container": "/var/lib/mysql",
            "user": "mysql",
            "group": "mysql"
          },
          {
            "host": "/eol/data/db_sysopia/var/log/mysql",
            "container": "/var/log/mysql",
            "user": "mysql",
            "group": "mysql"
          }
        ],
        "env_files": [
          "/eol/config/production.env"
        ],
        "params": {
          "version": "5.1",
          "image": "encoflife/mysql",
          "binlog": "false",
          "server_id": "1",
          "innodb_buffer_pool_size": "10G"
        }
      },
      {
        "name": "sysopia",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "ports": [{ "host": 9999, "container": 8080 }],
        "env_files": [ "/eol/config/sysopia.env" ],
        "params": {
          "version": "latest",
          "image": "encoflife/sysopia"
        }
      },
      {
        "name": "resque",
        "service_files": {
          "start_template": "start.erb",
          "stop_template": "stop.erb",
          "restart_template": "restart.erb"
        },
        "env_files": [
          "/eol/config/production.env"
        ],
        "volumes": [
          {
            "host": "/eol/data/resque/log",
            "container": "/app/log"
          }
        ],
        "params": {
          "version": "latest",
          "image": "encoflife/resque"
        }
      }
    ]
  }
}
```


Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Dmitry Mozzherin
