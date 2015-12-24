Percona test lab CHANGELOG
===========================


1.0.2
-----
- Fixed setup.rb

1.0.1
-----
- Fixed urls

1.0.0
-----
- Updated dist.tgz
- Added setup.rb to install, customize and run Percona server
- Updated README
- Fixed setup.rb & test.rb
- Made a video demo

0.2.1
-----
- Fix path to my.cnf config file for Debian OS family
- Set default Debian password for mysql

0.2.0
-----
Percona and Percona-multi cookbooks refactored due several problems on CentOS 7.1:
- mysql-chef_gem could not be installed, as percona package conflicts with myql-dev
- percona cookbook must be patched, as /etc/mysql/conf.d directory does not exist for rhel systems and lead to mysql service failing
- mysql server_id was not unique for virtual box environment, where all boxes have common nat interface

0.1.0
-----
Initial commit

