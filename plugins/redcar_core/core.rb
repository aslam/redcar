

module Redcar
  module Plugins
    module Core
      extend FreeBASE::StandardPlugin
      
      def self.load(plugin)
        $BUS = plugin.core.bus
        require File.dirname(__FILE__) + '/redcar'
        plugin.transition(FreeBASE::LOADED)
      end
      
      def self.start(plugin)
        Redcar.main_startup(:output => :silent)
        plugin["/system/ui/messagepump"].set_proc do
          begin
            Gtk.main
          rescue => e
            $stderr.puts str=<<ERR

---------------------------
Redcar has crashed.
---------------------------
Check #filename for backups of your documents. Redcar will 
notice these backups and prompt for recovery if you restart.

Please report this error message to the Redcar mailing list, along
with the actions you were taking at the time:

Time: #{Time.now}
Message: #{e.message}
Backtrace: \n#{e.backtrace.map{|l| "    "+l}.join("\n")}
Uname -a: #{`uname -a`.chomp}
ERR
          ensure
            plugin["/system/shutdown"].call(1)
          end
        end
        plugin.transition(FreeBASE::RUNNING)
      end
    end
  end
end
