eol-docker Cookbook
===================
This cookbook installs docker and creates EOL infrastructure according to
eol-docker/infrastructure data bag

Requirements
------------

#### cookbooks
- `docker` - eol-docker needs docker cookbook to install and configure docker

Attributes
----------

#### eol-docker::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['eol-docker']['todo']</tt></td>
    <td>Boolean</td>
    <td>Add attributes here</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
-----
#### eol-docker::default

* Create data bag that describes your infrastructure
* Include `eol-docker` in your node's `run_list`:

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
