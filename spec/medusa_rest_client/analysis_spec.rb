require 'spec_helper'
module MedusaRestClient
  describe Analysis do
    describe ".download" do
      subject { obj.download_casteml }
      let(:filename){ global_id + ".pml" }
      let(:obj){ FactoryBot.remote(:analysis) }
      let(:obj_id){ 100 }
      let(:global_id){ '0000-001' }
      before do
        allow(obj).to receive(:global_id).and_return(global_id)
        stub_request(:get, %r|/analyses/#{obj.id}.json|).to_return(:body => nil, :status => ["201", ""])
      end

      it { 
        subject
        expect(File.exist?(filename)).to be_truthy
      }

      after do
        File.unlink(filename)
      end
    end

    describe ".save" do
      let(:obj){ FactoryBot.remote(:analysis) }
#     let(:obj){ Analysis.new(:name => 'hello') }
      before do
#       setup
#       WebMock.allow_net_connect!
        obj
        stub_request(:post, %r|/analyses.json|).to_return(:body => nil, :status => ["201", ""])
      end

      it { expect{obj.save}.not_to raise_error }
      after do
#       WebMock.disable_net_connect!
      end
    end
  end
end
