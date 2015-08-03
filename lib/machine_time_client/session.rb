require "active_resource"
require "machine_time_client"
module MachineTimeClient
	class Session < ActiveResource::Base
		self.site = MachineTimeClient.site
		self.prefix = MachineTimeClient.prefix
	end
end
