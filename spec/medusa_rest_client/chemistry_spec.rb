require 'spec_helper'
module MedusaRestClient

  describe Chemistry do
    before do
      ActiveResource::Base.logger = Logger.new(STDOUT)
        ActiveResource::Base.logger.level = Logger::DEBUG
    end

    describe "analysis.chemistries" do
      subject{ analysis.chemistries }
      let(:analysis){ FactoryBot.remote(:analysis, id: 2530) }
      before do
        analysis
        stub_request(:get, %r|/analyses/#{analysis.id}/chemistries.json|).to_return(:body => [].to_json, :status => ["200", ""])
      end

      it { 
        subject
        expect(WebMock).to have_requested(:get, %r|/analyses/#{analysis.id}/chemistries.json|)
      }
    end

    describe ".create" do
      #let(:analysis){ Analysis.create(:name => 'deleteme')}
      let(:analysis){ double('analysis', :id => 110, :name => 'test').as_null_object }
      before do
        stub_request(:post, %r|/analyses/110/chemistries.json|).to_return(:body => {:id => 1, :name => "hello"}.to_json, :status => ["201", "Created"])
      end
      context "with analysis" do
        let(:chemistry_1){ Chemistry.new(:measurement_item_id => 198, :value => 0.123 ) }
        before do
          chemistry_1.analysis = analysis
        end
        #it { expect(analysis).not_to be_nil }
        it { 
          #expect(WebMock).to have_requested(:post, %r|/analyses/110/chemistries.json|)
          expect{ chemistry_1.save }.not_to raise_error
        }
      end

      context "with analysis_id" do
        let(:chemistry_1){ Chemistry.new(:measurement_item_id => 198, :value => 0.123, :analysis_id => analysis.id ) }
        it { 
          #expect(WebMock).to have_requested(:post, %r|/analyses/110/chemistries.json|)
          expect{ chemistry_1.save }.not_to raise_error
        }
      end

    end

    describe ".unit=" do
      let(:chem_1){ Chemistry.new(:measurement_item_id => 198, :value => 0.155) }
      let(:unit){ double("unit", :id => 1 )}

      before do
        chem_1.unit = unit
      end
      it { expect(chem_1.unit_id).to be_eql(unit.id)}
    end

    # describe "#unit" do
    #   let(:chem_1){ FactoryBot.remote(:chemistry, id: object_id) }
    #   let(:object_id){ 10 }     
    #   #let(:chem_attrib){ {:analysis_id => analysis.id, :measurement_item_id => 198, :value => 0.155, :unit_id => unit.id} }
    #   let(:analysis){ double(:analysis)}
    #   let(:unit){ double(:unit) }
    #   before do
    #     unit
    #     analysis
    #     chem_1
    #     stub_request(:get, %r|/analyses/#{analysis.id}/chemistries.json|).to_return(:body => [].to_json, :status => ["200", ""])

    #   end
    #   it { expect(chem_1.unit).to be_eql(unit) }
    #   after do
    #     analysis.destroy
    #   end
    # end

    # describe "analysis.create_chemistry" do
    #   let(:analysis){ Analysis.create(:name => 'deleteme')}
    #   let(:attrib){ {:measurement_item_id => 198, :value => 0.155} }
    #   before do
    #     analysis
    #   end
    #   it { expect{analysis.create_chemistry(attrib)}.not_to raise_error}
    #   after do
    #     analysis.destroy
    #   end


    # end
    after do
#     WebMock.disable_net_connect!
    end

  end
end
