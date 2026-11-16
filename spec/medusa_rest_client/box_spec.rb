require 'spec_helper'

module MedusaRestClient
  describe Box do
    before do
      setup
      WebMock.reset!
    end

    describe "entries" do
      subject { Box.entries(path) }
      before do
        setup
        allow(Box).to receive(:find_by_path).with(path).and_return([])
      end


      context "with root path" do
        let(:path){ "/" }
        before do
          path
        end
        it { 
          expect(Box).to receive(:find_by_path).with(path)
          subject
         }
      end


      context "with fullpath" do
        let(:path){ "/ISEI/main/clean-lab" }
        before do
          path
        end
        it { 
          expect(Box).to receive(:find_by_path).with(path)
          subject
         }
      end

      context "with relative path" do
        let(:path){ "./clean-lab" }
        before do
          path
        end
        it { 
          expect(Box).to receive(:find_by_path).with(path)
          subject
         }
      end

      # context "with invalid path" do
      #   let(:path){ "/ISEI/main/clean-l" }
      #   before do
      #     path
      #   end
      #   it { expect{Box.entries(path)}.to raise_error(RuntimeError) }
      # end

    end

    describe "on_root" do
      subject{ Box.on_root }
      let(:boxes){ double('boxes').as_null_object }
      it { 
        expect(Box).to receive(:find).with(:all, {:params => {:q => {:path_blank => true}}}).and_return(boxes)
        subject
       }
    end

    describe "inventory" do
      subject{ box.inventory item}
      let(:box){ FactoryBot.remote(:box, id: box_id) }
      let(:box_id){ 10 }
      context "with specimen" do
        let(:item){ FactoryBot.remote(:specimen, id: 100) }
        before do
          stub_request(:post, %r|/boxes/#{box.id}/specimens/#{item.id}/inventory.json|).to_return(:body => [].to_json, :status => ["200", ""])
        end
        it {
          subject
          expect(WebMock).to have_requested(:post, %r|/boxes/#{box.id}/specimens/#{item.id}/inventory.json|)
        }
      end

      context "with box" do
        let(:item){ FactoryBot.remote(:box, id: 200 ) }
        before do
          stub_request(:post, %r|/boxes/#{box.id}/boxes/#{item.id}/inventory.json|).to_return(:body => [].to_json, :status => ["200", ""])
        end
        it {
          subject
          expect(WebMock).to have_requested(:post, %r|/boxes/#{box.id}/boxes/#{item.id}/inventory.json|)
        }
      end

    end
    
    describe "parent" do
      subject{ box.parent }
      let(:box){ FactoryBot.remote(:box, id: box_id, parent_id: parent_id) }
      let(:box_id){ 10 }
      context "with existing parent_id" do
        let(:parent_id){ 11 }
        before do
          box
        end
        it { 
          expect(Box).to receive(:find).with(parent_id)
          subject 
        }
      end

      context "with null parent_id" do
        let(:parent_id){ nil }
        before do
          box
        end
        it { 
          expect(Box).not_to receive(:find).with(parent_id)
          subject 
        }
      end

    end

    describe "box" do
      subject{ box.box }
      let(:box){ FactoryBot.remote(:box, id: box_id, parent_id: parent_id) }
      let(:box_id){ 10 }
      let(:parent_id){ 11 }
      before do
        box
      end
      it { 
        expect(Box).to receive(:find).with(parent_id) 
        subject
      }

    end

    describe "pwd_id" do
      let(:pwd_id){ '11111-11' }
      before do
        Box.pwd_id = pwd_id
      end
      it { expect(Box.pwd_id).to eq(pwd_id) }
    end

    describe "pwd" do
      subject{ Box.pwd } 
      let(:box){ FactoryBot.remote(:box, id: box_id, global_id: global_id, name: 'test-box') }
      let(:box_id){ 10 }
      let(:global_id){ '1111-001' }
      context "when valid pwd_id" do
        before do
          Box.pwd_id = global_id
        end
        it { 
          expect(Record).to receive(:find).with(global_id).and_return(box)
          subject
        }
      end

      context "when pwd_id = nil" do
        before do
          Box.pwd_id = nil
        end
        it { expect(Box.pwd).to eq('/')}
      end

      context "when pwd_id = ''" do
        before do
          Box.pwd_id = ''
        end
        it { expect(Box.pwd).to eq('/')}
      end

    end

    describe "find_by_path" do
      subject { Box.find_by_path(path) }
      let(:box){ FactoryBot.remote(:box) }

      context "with absolute path" do
        let(:path){'/ISEI/main'}
        it { 
          expect(Box).to receive(:find).with(:first, :params => {:q => {:name_eq => 'main', :m => 'and', :path_eq => '/ISEI'}}).and_return(box)
          subject
        }
      end

      context "with root path" do
        let(:path){'/'}
        it { 
          expect(BoxRoot).to receive(:new)
          subject
        }

      end


      context "with relative path" do
        let(:path){'ISEI'}
        it { 
          expect(Box).to receive(:find).with(:first, :params => {:q => {:name_eq => path, :m => 'and', :path_blank => true}}).and_return(box)
          subject
        }

      end

      context "with empty path" do
        let(:path){''}
        it { 
          expect(BoxRoot).to receive(:new)
          #expect(Box).to receive(:find).with(:first, :params => {:q => {:name_eq => path, :m => 'and', :path_blank => true}}).and_return(box)
          subject
        }
      end


    end

    describe "home=" do
      subject{ Box.home = home_path } 
      let(:home){ FactoryBot.remote(:box) }
      let(:global_id){ '000-001' }
      let(:home_path){ '/ISEI/main'}
      it {
        expect(Box).to receive(:find).with(:first, :params=>{:q => {:name_eq => 'main', :m => 'and', :path_eq => '/ISEI'}}).and_return(home)
        expect(home).to receive(:global_id).and_return(global_id)
        subject
      }

    end

    describe "chdir" do
      subject{ Box.chdir(path) } 
      let(:home_path){ '/ISEI/main'}
      let(:global_id){ '0000-001' }
      before do
        allow(Box).to receive(:home).and_return(home_path)
      end

      context "without path and blank home" do
        let(:path){ nil }
        before do
          allow(Box).to receive(:home).and_return(nil)
        end

        it { 
          expect(Box).to receive(:find_by_path).with(nil)
          subject
        }
      end

      context "without path and home" do
        # before do
        #   Box.chdir(path)
        # end
        let(:path){ nil }
        let(:home_path){ '/ISEI/main'}
        it {
          expect(Box).to receive(:find_by_path).with(home_path)        
          subject
        }
      end

      context "with empty path and home" do
        let(:path){ "" }
        let(:home_path){ '/ISEI/main'}
        it { 
          expect(Box).to receive(:find_by_path).with(home_path)        
          subject
        }
      end


      context "with relative path and pwd" do
        before do
          Box.pwd_id = pwd_id
        end
        let(:pwd_id){ '1111-110' }
        let(:path){ 'main'}
        it {
          expect(Box).to receive(:find_by_path).with(path)    
          subject            
        }       
      end

      context "with relative path and no pwd" do
        before do
          Box.pwd_id = nil
        end
        let(:path){ 'ISEI'}
        it {
          expect(Box).to receive(:find_by_path).with(path)    
          subject            
        }       

      end

    end

    describe "relatives" do
      let(:stone_1) { FactoryBot.build(:stone)}
      let(:obj) { Box.find(obj_id)}
      let(:obj_id) { 10 }
      before do
        FactoryBot.remote(:box, id: obj_id)
        stub_request(:post, %r|/boxes/#{obj.id}/specimens.json|).to_return(:body => nil, :status => ["201", ""])
        obj.relatives << stone_1
      end
      it { expect(nil).to be_nil }
    end

    describe "stones" do
      let(:stone_1) { FactoryBot.build(:stone)}
      let(:obj) { Box.find(obj_id)}
      let(:obj_id) { 10 }
      before do
        FactoryBot.remote(:box, id: obj_id)
        stub_request(:post, %r|/boxes/#{obj.id}/specimens.json|).to_return(:body => nil, :status => ["201", ""])
        obj.stones << stone_1
      end
      it { expect(nil).to be_nil }
    end

  end
end