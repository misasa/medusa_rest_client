require 'spec_helper'

module MedusaRestClient
  describe MyAssociation do

    describe "without subclass" do
      before do
        setup
        FakeWeb.clean_registry
      end
  
      let(:association){ MyAssociation.new(obj) }
      let(:obj) { Box.find(obj_id)}
      let(:obj_id) { 10 }
      let(:stone_1){ FactoryGirl.build(:stone) }
      let(:box_1){ FactoryGirl.build(:box) }
      let(:box_2){ FactoryGirl.build(:box) }        
      before do
        setup
        FactoryGirl.remote(:box, id: obj_id)
      end

      context "#<<" do
        before do
          FakeWeb.register_uri(:post, %r|#{association.collection_path(stone_1)}|, :body => nil, :status => ["201", ""])                        
          association << stone_1
        end
        it { expect(FakeWeb).to have_requested(:post, %r|#{association.collection_path(stone_1)}|) }
      end

      context "#.to_a" do
        before do
          FakeWeb.register_uri(:get, %r|boxes/#{obj.id}/specimens.json|, :body => [stone_1].to_json, :status => ["200", ""])                        
          FakeWeb.register_uri(:get, %r|boxes/#{obj.id}/boxes.json|, :body => [box_1, box_2].to_json, :status => ["200", ""])                       
          FakeWeb.register_uri(:get, %r|boxes/#{obj.id}/attachment_files.json|, :body => [].to_json, :status => ["200", ""])                        
          FakeWeb.register_uri(:get, %r|boxes/#{obj.id}/bibs.json|, :body => [].to_json, :status => ["200", ""])                        
          association.to_a
        end
        it { expect(FakeWeb).to have_requested(:get, %r|boxes/#{obj.id}/specimens.json|) }        
        it { expect(FakeWeb).to have_requested(:get, %r|boxes/#{obj.id}/boxes.json|) }        
        it { expect(FakeWeb).to have_requested(:get, %r|boxes/#{obj.id}/attachment_files.json|) }       
        it { expect(FakeWeb).to have_requested(:get, %r|boxes/#{obj.id}/bibs.json|) }       
      end

    end

    describe "with subclass" do
      let(:association){ MyAssociation.new(obj, Specimen) }
      let(:obj) { Box.find(obj_id)}
      let(:obj_id) { 10 }
      let(:stones) { [stone_1] }
      let(:stone_1){ FactoryGirl.build(:stone) }

      before do
        setup
        FactoryGirl.remote(:box, id: obj_id)
        FakeWeb.register_uri(:get, %r|boxes/#{obj.id}/stones.json|, :body => stones.to_json, :status => ["200", ""])                        
      end
      context "#to_a" do
        before do
          association.to_a
        end
        it { expect(FakeWeb).to have_requested(:get, %r|boxes/#{obj.id}/specimens.json|) }
      end

      context "#<<" do
        before do
          FakeWeb.register_uri(:post, %r|#{association.collection_path(stone_1)}|, :body => nil, :status => ["201", ""])                        
          association << stone_1
        end
        it { expect(FakeWeb).to have_requested(:post, %r|#{association.collection_path(stone_1)}|) }
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
          FakeWeb.register_uri(:get, %r|boxes/#{obj.id}/specimens.json|, :body => [].to_json, :status => ["200", ""])                   
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
