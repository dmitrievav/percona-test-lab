Percona test lab
================
This is a Percona test lab. You can use test-kitchen, vagrant or even any virtual or hardware box to install Percona MySQL server and setup Master <-> Slave replication.

Installation
------------
- Directly on node
<pre><code>
curl -L -O https://raw.githubusercontent.com/dmitrievav/percona-test-lab/master/setup.rb
ruby ./setup.rb
</code></pre>

- Test-kitchen
<pre><code>
kitchen converge master-ubuntu-trusty64
kitchen converge slave-ubuntu-trusty64
</code></pre>
or
<pre><code>
kitchen converge master-bento-centos-71
kitchen converge slave-bento-centos-71
</code></pre>

Demo
--------------
[Watch demo](https://asciinema.org/a/32377)

Frameworks
----------
Deployment automation based on Chef configuration managment, as one of the most dynamic and widely used DevOps tool.

Includes forked comunity cookbooks:
- `percona`
- `percona-multi`

As well as not modifed comunity cookbooks:
- `apt`
- `build-essential`
- `chef-sugar`
- `openssl`
- `yum`

Prerequisites
-------------
### Supported OS

- CentOS 7.1
- Ubuntu 14.04

### Install and customize VirtualBox

- [Download virtualbox](https://www.virtualbox.org/wiki/Downloads)
- create host-only network vboxnet0 10.0.0.0/24
- set the route: `sudo route add 10.0.0.0/24 -interface vboxnet0`

### Install Vagrant

- [Download Vagrant](https://www.vagrantup.com/downloads.html)
- Install vagrant-berkshelf plugin
- Install vagrant-omnibus plugin

### Install ChefDK

- [Download ChefDK](https://downloads.chef.io/chef-dk/)

Content description
-------------------
- `setup.rb` - for fetching and all setup related tasks
- `test.rb` - for running the test suit on Slave node
- `CHANGELOG.md` - Percona test lab CHANGELOG
- `.kitchen.yml` - Test-kitchen settings
- `Vagrantfile.erb` - Vagrant custom settings
- `cookbooks/*` - Chef community and foked cookbooks
- `dist & dist.tgz` - chef-zero repo, that is used by setup.rb
