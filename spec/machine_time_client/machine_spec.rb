require 'spec_helper'
require 'machine_time_client/machine'

module MachineTimeClient
	describe Machine do
		let(:config){ {:uri_machine => uri_machine, :machine => machine_name }}
		let(:uri_machine){ "http://database.misasa.okayama-u.ac.jp/machine/"}
		let(:machine_name){ "JXA-8800"}
		before do
			allow(MachineTimeClient).to receive(:config).and_return(config)
		end

		describe ".running?" do
			subject { Machine.is_running? }
			let(:machine_obj){ double('machine').as_null_object }
			before do
				allow(Machine).to receive(:instance).and_return(machine_obj)
			end
			it { 
				expect(machine_obj).to receive(:is_running?)
				subject
			}
		end

		after do
			#machine.stop
		end



	end
end
