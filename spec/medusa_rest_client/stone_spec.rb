require 'spec_helper'

module MedusaRestClient
  describe Stone do
    before do
      setup
      WebMock.reset!
    end



    describe "find_by_path" do
      context "with absolute path" do
        subject{ Stone.find_by_path(path) }
        let(:path){ '/ISEI/main/clean-lab/Allende' }
        let(:stone){ double(:stone) }
        let(:box){ double(:box, :id => box_id).as_null_object }
        let(:box_id){ 10 }
        before do
          allow(Box).to receive(:find_by_path).and_return(box)
          allow(Stone).to receive(:find).and_return(stone)
        end
        it {
          expect(Box).to receive(:find_by_path).with(File.dirname(path)).and_return(box)
          expect(Stone).to receive(:find).with(:first, :params => {:q => {:name_eq => File.basename(path), :m => 'and', :box_id_eq => box_id}}).and_return(stone)
          subject
        }
      end

      context "with root path" do
        subject{ Stone.find_by_path(path) }
        let(:path){ '/deleteme-1' }
        let(:stone){ double(:stone) }
        before do
          #@stone = Stone.find_by_path(path)
        end
        it {
          expect(Stone).to receive(:find).with(:first, :params => {:q => {:name_eq => File.basename(path), :m => 'and', :box_id_blank => true}}).and_return(stone)
          subject
        }
      end

      context "with relative path on root" do
        subject{ Stone.find_by_path(path) }
        let(:path){ 'deleteme-1' }
        let(:stone){ double(:stone) }
        before do
          Box.chdir("/")
        end
        it { 
          expect(Stone).to receive(:find).with(:first, :params => {:q => {:name_eq => File.basename(path), :m => 'and', :box_id_blank => true}}).and_return(stone)
          subject
        }
      end

      context "with relative path on /ISEI/main/clean-lab" do
        subject{ Stone.find_by_path(path) }
        let(:pwd) {'/ISEI/main/clean-lab'}
        let(:path){ 'Allende' }
        let(:stone){ double(:stone) }
        let(:box){ double(:box, id: box_id ) }
        let(:box_id){ 100 }
        before do
          allow(Box).to receive(:pwd).and_return(pwd)
          allow(Box).to receive(:find_by_path).with(pwd).and_return(box)
        end
        it {
          expect(Stone).to receive(:find).with(:first, :params => {:q => {:name_eq => File.basename(path), :m => 'and', :box_id_eq => box_id}}).and_return(stone)
          subject 
        }
      end

      context "with relative invalid path on /ISEI/main/clean-lab" do
        subject{ Stone.find_by_path(path) }
        let(:pwd) {'/ISEI/main/clean-lab'}
        let(:path){ 'Alle' }
        let(:box){ double(:box, id: box_id ) }
        let(:box_id){ 100 }
        let(:stone){ double(:stone) }
        before do
          allow(Box).to receive(:pwd).and_return(pwd)
          allow(Box).to receive(:find_by_path).with(pwd).and_return(box)
          allow(Stone).to receive(:find)
        end
        it { 

          expect{ subject }.to raise_error(RuntimeError)  
        }
      end

    end

    describe "box" do
      subject{ stone.box }
      let(:stone) { Stone.find(stone_id)}
      let(:stone_id) { 10 }
      let(:box_id){ 100 }
      before do
        FactoryBot.remote(:stone, id: stone_id, box_id: box_id)
      end
      it { 
        expect(Box).to receive(:find).with(box_id)
        subject
       }
    end

    describe "#upload_file" do
      let(:upload_file){ 'tmp/upload.txt' }
      before do
        setup_empty_dir('tmp')
        setup_file(upload_file)
        stone = FactoryBot.build(:stone, id: 10)
        stub_request(:post, %r|/specimens/10/attachment_files.json|).to_return(:body => FactoryBot.build(:attachment_file).to_json, :status => ["201", "Created"])
        stone.upload_file(:file => upload_file, :filename => 'example.txt')
      end
      it { expect(WebMock).to have_requested(:post, %r|/specimens/10/attachment_files.json|) }
    end

    describe "#upload_file with tmpfile" do
      #let(:upload_file){ tempfile.path }
      let(:temp){ Tempfile.new('foo') }
      before do
        #temp = Tempfile.new('foo')
        temp.write "Hello world"
        temp.close
        #setup_empty_dir('tmp')
        #setup_file(upload_file)
        stone = FactoryBot.build(:stone, id: 10)
        stub_request(:post, %r|/specimens/10/attachment_files.json|).to_return(:body => FactoryBot.build(:attachment_file).to_json, :status => ["201", "Created"])
        stone.upload_file(:file => temp.path, :filename => 'example.txt')
      end
      it { expect(WebMock).to have_requested(:post, %r|/specimens/10/attachment_files.json|) }
    end



  end
end