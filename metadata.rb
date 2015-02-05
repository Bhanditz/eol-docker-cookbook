name             'eol-docker'
maintainer       'Dmitry Mozzherin'
maintainer_email 'dmozzherin@gmail.com'
license          'MIT'
description      'Installs/Configures eol-docker'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.8'

depends "apt", "~>2.6"
depends "yum-epel", "~>0.6"
