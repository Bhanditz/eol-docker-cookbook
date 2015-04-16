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

Create data bag that describes your infrastructure

```bash

```
* Include `eol-docker` in your node's `run_list`, or include recipe to your
cookbook:

```json
{
  "name":"my_node",
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
