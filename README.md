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
have `production` as their `chef_environment`.

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
