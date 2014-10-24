require "machine_time_client"
module MachineTimeClient
  class Machine < ActiveResource::Base
  	self.site = MachineTimeClient.site
  	self.prefix = MachineTimeClient.prefix
  end
end
