require 'spec_helper'
require 'machine_time_client/machine'
module MachineTimeClient
	describe ".config" do
		it { expect(MachineTimeClient.config).to include(:uri)}
		it { expect(MachineTimeClient.config).to include(:machine)}
	end
	describe ".site" do
		it { expect(MachineTimeClient.site).to include("http://")}
	end

	describe Machine, :current => true do
		it { expect(Machine.all).to be_nil }
	end
	# describe Server do
	# 	it { expect("hello").to eql("hello") }
	# end
end
