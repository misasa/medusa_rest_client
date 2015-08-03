require 'spec_helper'
require 'machine_time_client/runner'
module MachineTimeClient
	describe Runner do
		describe "#run" do
			subject { runner.run(args, :command_name => command_name )}
			let(:manager){ MachineTimeClient::CommandManager.instance }
			let(:runner){ Runner.new }
			let(:command_name){ 'machine_command' }
			let(:args){ ['start'] }
			let(:cmd){ double('start').as_null_object }
			it {
				expect(manager).to receive(:load_and_instantiate).with('machine_command', args, {:command_name => command_name}).and_return(cmd)
				expect(cmd).to receive(:run)
				subject
			}
		end
	end
end