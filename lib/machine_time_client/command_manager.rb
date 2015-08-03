module MachineTimeClient
	class CommandManager
		def self.instance
			@command_manager ||= new
		end

		def load_and_instantiate(command_name, args, opts = {})
			require "machine_time_client/commands/#{command_name}"
			const_name = command_name.capitalize.gsub(/_(.)/) { $1.upcase }
			MachineTimeClient::Commands.const_get(const_name).new(args, opts)
		end
	end
	module Commands
	end
end