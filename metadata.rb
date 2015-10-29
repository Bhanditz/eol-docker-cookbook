name             'eol-docker'
maintainer       'Jeremy Rice'
maintainer_email 'jrice@eol.org'
license          'MIT'
description      'Installs/Configures eol-docker'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.9'

depends "apt", "~>2.6"
depends "yum-epel", "~>0.6"
