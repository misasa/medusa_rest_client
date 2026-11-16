require 'spec_helper'

module MedusaRestClient
  describe MyAssociation do

    describe "without subclass" do
      before do
        setup
        WebMock.reset!
      end
  
      let(:association){ MyAssociation.new(obj) }
      let(:obj) { Box.find(obj_id)}
      let(:obj_id) { 10 }
      let(:stone_1){ FactoryBot.build(:stone) }
      let(:box_1){ FactoryBot.build(:box) }
      let(:box_2){ FactoryBot.build(:box) }
      before do
        setup
        FactoryBot.remote(:box, id: obj_id)
      end

      context "#<<" do
        before do
          stub_request(:post, %r|#{association.collection_path(stone_1)}|).to_return(:body => nil, :status => ["201", ""])
          association << stone_1
        end
        it { expect(WebMock).to have_requested(:post, %r|#{association.collection_path(stone_1)}|) }
      end

      context "#.to_a" do
        before do
          stub_request(:get, %r|boxes/#{obj.id}/specimens.json|).to_return(:body => [stone_1].to_json, :status => ["200", ""])
          stub_request(:get, %r|boxes/#{obj.id}/boxes.json|).to_return(:body => [box_1, box_2].to_json, :status => ["200", ""])
          stub_request(:get, %r|boxes/#{obj.id}/attachment_files.json|).to_return(:body => [].to_json, :status => ["200", ""])
          stub_request(:get, %r|boxes/#{obj.id}/bibs.json|).to_return(:body => [].to_json, :status => ["200", ""])
          association.to_a
        end
        it { expect(WebMock).to have_requested(:get, %r|boxes/#{obj.id}/specimens.json|) }
        it { expect(WebMock).to have_requested(:get, %r|boxes/#{obj.id}/boxes.json|) }
        it { expect(WebMock).to have_requested(:get, %r|boxes/#{obj.id}/attachment_files.json|) }
        it { expect(WebMock).to have_requested(:get, %r|boxes/#{obj.id}/bibs.json|) }
      end

    end

    describe "with subclass" do
      let(:association){ MyAssociation.new(obj, Specimen) }
      let(:obj) { Box.find(obj_id)}
      let(:obj_id) { 10 }
      let(:stones) { [stone_1] }
      let(:stone_1){ FactoryBot.build(:stone) }

      before do
        setup
        FactoryBot.remote(:box, id: obj_id)
        stub_request(:get, %r|boxes/#{obj.id}/specimens.json|).to_return(:body => stones.to_json, :status => ["200", ""])
      end
      context "#to_a" do
        before do
          association.to_a
        end
        it { expect(WebMock).to have_requested(:get, %r|boxes/#{obj.id}/specimens.json|) }
      end

      context "#<<" do
        before do
          stub_request(:post, %r|#{association.collection_path(stone_1)}|).to_return(:body => nil, :status => ["201", ""])
          association << stone_1
        end
        it { expect(WebMock).to have_requested(:post, %r|#{association.collection_path(stone_1)}|) }
      end

      context "#inspect" do
        before do
          association
        end
        it { 
          allow(association).to receive(:to_a) 
          association.inspect
        }
      end

      context "#.size" do
        before do
          association
        end
        it {
          expect(association.size).to eq(1)
        }
      end

      context "#.empty?" do
        before do
          stub_request(:get, %r|boxes/#{obj.id}/specimens.json|).to_return(:body => [].to_json, :status => ["200", ""])
          association
        end
        it {
          expect(association.size).to eq(0)
          expect(association.empty?).to be_truthy
        }
      end
      context "#each" do
        before do
          association.each do |a|
            p a
          end
        end
        it { expect(nil).to be_nil }
      end

    end
  end
end
