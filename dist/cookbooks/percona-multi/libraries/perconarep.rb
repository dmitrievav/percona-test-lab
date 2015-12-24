class Chef
  class Recipe
    # Run mysql client, grab binlog and binpos and pass back as variables
    class PerconaRep
      extend Chef::Mixin::ShellOut
      def self.query query, username = nil, password = nil, host = nil, dbname = nil
        # query could be a String or an Array of String
        statement = query.is_a?(String) ? query : query.join("\n")
        puts "\n- Running SQL statement:\n#{statement}".gsub(/(password(=|\s))([^\s]*|\'.*?\'|\".*?\")/i, "\\1sensored")
        @execute_sql = begin
          cmd_params = "/usr/bin/mysql -B " +
          "#{host.nil? ? '' : '-h ' + host} " +
          "#{dbname.nil? ? '' : '-D ' + dbname} " +
          "#{username.nil? ? '' : '-u ' + username} " +
          "#{password.nil? ? '' : '--password=' + password} "
          cmd = shell_out(cmd_params,
                :input => statement
          )
          # Instead of aborting chef with a fatal error, let's just
          # pass these non-zero exitstatus back as empty cmd.stdout.
          if (cmd.exitstatus() == 0 and !cmd.stderr.empty? and cmd.stderr !~ /Warning/)
            # An SQL failure is still a zero exitstatus, but then the
            # stderr explains the error, so let's rais that as fatal.
            Chef::Log.fatal(cmd.stdout) unless cmd.stdout.empty?
            Chef::Log.fatal(cmd.stderr)
            raise "SQL ERROR"
          end
          if (cmd.exitstatus() != 0)
            Chef::Log.fatal(cmd.stdout) unless cmd.stdout.empty?
            Chef::Log.fatal(cmd.stderr)
            raise "SQL ERROR"
          end
          puts "STDOUT: \n#{cmd.stdout}\n" unless cmd.stdout.empty?
          cmd.stdout.chomp
        end
      end
      def self.bininfo(host, username, password)
        h = query('show master status', username, password, host)
        #p h
        log = h.split("\n")[1].split("\t")[0]
        pos = h.split("\n")[1].split("\t")[1]
        return log, pos
      end
=begin
      def self.query(host, username, password, query)
        require 'rubygems'
        require 'mysql'
        m = Mysql.new(host, username, password)
        r = m.query(query)
        return r.fetch_hash
      end
      def self.bininfo(host, username, password)
        h = query(host, username, password, 'show master status')
        p h
        log = h['File']
        pos = h['Position']
        return log, pos
      end
=end

    end
  end
end
