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
options.slave       = nil
options.password    = nil

$opts = OptionParser.new
$opts.banner = "Usage: #{__FILE__} -m MASTER_IP -s SLAVE_IP [-p PASSWORD]"
$opts.separator ""
$opts.separator "Specific options:"
$opts.on('-m', '--master MASTER_IP', 'Percona master server IP') { |v|
  options.master = v
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
  puts $opts
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

def test master, slave, password
  if not master.nil? and not slave.nil?
    puts "MASTER STATUS:"
    system %Q{echo 'SHOW MASTER STATUS' \
      | mysql -h #{master} -u replicant #{password.nil? ? '': '--password=' + password}}
    puts "SLAVE STATUS:"
    system %Q{echo 'SHOW SLAVE STATUS \\G' \
      | mysql -u root #{password.nil? ? '': '--password=' + password} \
      | egrep 'Slave_IO_State|Master_Host|Master_Log_File|Read_Master_Log_Pos|Last_Error|Last_SQL_Error|SQL_Delay'}
  else
    puts $opts.help
    exit(1)
  end
end

test options.master, options.slave, options.password


