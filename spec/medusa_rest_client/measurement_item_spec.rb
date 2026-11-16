require 'medusa_rest_client'
require 'spec_helper'

module MedusaRestClient
  describe MeasurementItem do

    describe ".find_by_nickname" do
#     subject { MeasurementItem.find(:first, :params => {:q => {:nickname_eq => nickname}} ) }
      subject { MeasurementItem.find_by_nickname(nickname) }
      context "with item exists" do
        let(:nickname){ 'Be' }
        before do
          nickname
        end
        it {
          expect(MeasurementItem).to receive(:find).with(:first, {:params=>{:q=>{:nickname_eq=>"Be"}}}) 
          subject 
        }
      end

    end

    describe ".find_or_create_by_nickname" do
      subject { MeasurementItem.find_or_create_by_nickname(nickname) }

      let(:nickname){ 'Be-deleteme' }
      before do
        nickname
        stub_request(:post, %r|/measurement_items.json|).to_return(:body => {:id => 1, :name => "hello"}.to_json, :status => ["201", "Created"])
      end
      it {  
        expect(MeasurementItem).to receive(:find).with(:first, {:params=>{:q=>{:nickname_eq=>"Be-deleteme"}}}) 
        subject
        expect(WebMock).to have_requested(:post, %r|/measurement_items.json|)
      }
    end
    
  end

end
