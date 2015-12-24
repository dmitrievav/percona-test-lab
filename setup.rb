#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'optparse'
require 'ostruct'
require 'json'

#################################
# Read options
#
argv_empty = true if ARGV.empty?
#options = {}

options             = OpenStruct.new
options.master      = nil
options.slaves_list = nil
options.slave       = nil
options.password    = nil
config_file         = "/tmp/kitchen/dna.json"

$opts = OptionParser.new
$opts.banner = "Usage: #{__FILE__} -m MASTER_IP < -l SLAVES_LIST | -s SLAVE_IP > [-p PASSWORD]"
$opts.separator ""
$opts.separator "Specific options:"
$opts.on('-m', '--master MASTER_IP', 'Percona master server IP') { |v|
  options.master = v
}
$opts.on('-l', '--slaves-list SLAVES_LIST', 'Percona slave servers IP list') { |v|
  options.slave = v
}
$opts.on('-s', '--slave SLAVE_IP', 'Percona slave server IP') { |v|
  options.slave = v
}
$opts.on('-p', '--password PASSWORD', 'MySQL replication and root password') { |v|
  options.password = v
}
begin
  $opts.parse!
rescue OptionParser::InvalidOption => e
  puts e
  puts opts
  puts $opts.help
  exit(1)
end
argv_not_processed = true unless ARGV.empty?

unless ARGV.empty? then
  puts "\nUnprocessed options:"
  ARGV.each do |a|
    puts "Argument: #{a}"
  end
  puts "---"
end

if argv_empty or argv_not_processed then
  puts $opts.help
  exit(1)
end

#
#################################

def update_chef_config config_file, master, slaves_list, slave, password
  if File.file?(config_file) and !File.directory?(config_file) then
    chef_config = JSON.parse(IO.read(config_file))
  else
    abort("File #{config_file} not found!")
  end
  unless master.nil?
    if slave.nil? and not slaves_list.nil?
      puts "Installing Percona master server ..."
      chef_config['percona']['master'] = master
      chef_config['percona']['slaves'] = slaves_list.gsub(/[,;]/, " ").split(" ")
      chef_config['percona']['server']['bind_address'] = master
      chef_config['run_list'] = ["recipe[percona-multi::master]"]
    elsif slaves_list.nil? and not slave.nil?
      puts "Installing Percona slave server ..."
      chef_config['percona']['master'] = master
      chef_config['percona']['server']['bind_address'] = slave
      chef_config['run_list'] = ["recipe[percona-multi::slave]"]
    else
      puts $opts.help
      exit(1)
    end
    unless password.nil?
      chef_config['percona']['server']['root_password'] = password
      chef_config['percona']['server']['debian_password'] = password
      chef_config['percona']['server']['replication']['password'] = password
    end
  else
    puts $opts.help
    exit(1)
  end
  # update chef config
  File.open(config_file, 'w') { |f| f.write(chef_config.to_json) }
end

def test master, slave, password
  if not master.nil? and not slave.nil?
    puts "MASTER STATUS:"
    system %Q{echo 'SHOW MASTER STATUS' \
      | mysql -h #{master} -u replicant #{password.nil? ? '': '--password=' + password}}
    puts "SLAVE STATUS:"
    system %Q{echo 'SHOW SLAVE STATUS \\G' \
      | mysql -u root #{password.nil? ? '': '--password=' + password} \
      | egrep 'Slave_IO_State|Master_Host|Master_Log_File|Read_Master_Log_Pos|Last_Error|Last_SQL_Error|SQL_Delay'}
  end
end

puts "Install chef-client ..."
system "curl -L https://www.chef.io/chef/install.sh | sudo bash"
abort("Unable to install chef-client") unless $?.success?

puts "Prepare chef cookbooks ..."
system '[ -d /tmp/kitchen ] || mkdir /tmp/kitchen \
&& cd /tmp/kitchen \
&& echo "Make sure that you can download dist.tgz !!!" \
&& curl -iL -O https://github.com/dmitrievav/percona-test-lab/blob/master/setup.rb \
&& tar xzvf dist.tgz 1>/dev/null'
#&& cp /vagrant/dist.tgz ./ \
abort("Unable to download dist.tgz") unless $?.success?

puts "Update chef config ..."
update_chef_config config_file, options.master, options.slaves_list, options.slave, options.password

puts "Deploy ..."
system 'sudo -E \
/opt/chef/bin/chef-client \
--local-mode \
--config /tmp/kitchen/client.rb \
--log_level auto \
--force-formatter \
--no-color \
--json-attributes /tmp/kitchen/dna.json \
--chef-zero-port 8889'
abort("Deploy failed") unless $?.success?

puts "Installation successfully completed\n"

test options.master, options.slave, options.password