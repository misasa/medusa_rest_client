require 'spec_helper'
require 'machine_time_client'

describe MachineTimeClient do
	describe "config" do
		subject { MachineTimeClient.config }
		before do
			MachineTimeClient.config = nil
		end

		it { 
			expect(MachineTimeClient).to receive(:read_config)
			subject
		}
	end

	describe ".uri" do
		subject { MachineTimeClient.uri }
		context "with config[:uri_machine]" do
			let(:config){ {:uri_machine => uri_machine } }
			let(:uri_machine){ "http://example.com/" }
			before do
				allow(MachineTimeClient).to receive(:config).and_return(config)				
			end
			it {
				expect{ subject }.not_to raise_error
			}
		end

		context "without config[:uri_machine]" do
			let(:config){ {:uri => uri_machine } }
			let(:uri_machine){ "http://example.com/" }
			before do
				allow(MachineTimeClient).to receive(:config).and_return(config)				
			end
			it {
				expect{ subject }.to raise_error(RuntimeError, /does not have parameter \|uri\_machine\|/)
			}
		end

	end

	describe ".machine_name" do
		subject { MachineTimeClient.machine_name }
		context "with config[:machine]" do
			let(:config){ {:machine => machine_name } }
			let(:machine_name){ "TMP-1270" }
			before do
				allow(MachineTimeClient).to receive(:config).and_return(config)				
			end
			it {
				expect{ subject }.not_to raise_error
			}

		end

		context "without config[:machine]" do
			let(:config){ {} }
			before do
				allow(MachineTimeClient).to receive(:config).and_return(config)				
			end
			it {
				expect{ subject }.to raise_error(RuntimeError, /does not have parameter \|machine\|/)
			}
		end

	end
end
