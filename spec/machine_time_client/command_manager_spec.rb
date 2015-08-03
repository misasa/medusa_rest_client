require 'spec_helper'
require 'machine_time_client/command_manager'
require 'machine_time_client/commands/machine_command'
module MachineTimeClient
	describe CommandManager do
		describe "#load_and_instantiate" do
			subject { manager.load_and_instantiate command_name, args, opts }
			let(:manager){ CommandManager.instance}
			let(:command_name){ 'machine_command' }
			let(:args){ [] }
			let(:opts){ {} }
			let(:cmd){ double('machine').as_null_object }
			it "returns command instance" do
				expect(MachineTimeClient::Commands::MachineCommand).to receive(:new).with(args, {})
				subject
			end
		end

	end
end