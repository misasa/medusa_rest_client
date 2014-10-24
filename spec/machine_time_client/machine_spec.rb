require 'spec_helper'
require 'machine_time_client/machine'

module MachineTimeClient
	describe Machine do
		before do
			#machine.start
		end
		let(:machine){ Machine.find(:first) }
		it { expect(machine.current_session).to be_nil }
		after do
			#machine.stop
		end
	end
end
