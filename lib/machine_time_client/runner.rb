require 'machine_time_client/command_manager'
module MachineTimeClient
	class Runner
		def initialize
		end
		def run(args=ARGV, opts = {})
			if command_name = opts[:command_name]
				command_name = opts[:command_name]
				cmd = MachineTimeClient::CommandManager.instance.load_and_instantiate command_name, args, opts
				cmd.run
			end
		end
	end
end