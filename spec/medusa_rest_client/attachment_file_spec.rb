require 'spec_helper'

module MedusaRestClient
  describe AttachmentFile do
    describe "self.get_affine_from_geo" do
      subject { AttachmentFile.get_affine_from_geo(geo_file)}
      let(:geo_file){ 'tmp/test_image.geo'  }
      before do
        setup_empty_dir('tmp')
        setup_file(geo_file)
      end
      it { expect(subject).to be_eql("[10, 0, 0;0, 10, 0;0, 0, 1]")}
    end

    describe ".save with new object" do
      let(:obj){ FactoryGirl.build(:attachment_file) }
      before do
        obj
      end
      it "calls create_with_upload_data" do
        allow(obj).to receive(:post_multipart_form_data)
        obj.save
      end
    end

    describe ".save with exsisting object", :current => true do
      let(:obj){ AttachmentFile.find(1) }
      let(:obj2){ Specimen.find(1)}
      before do
        FactoryGirl.remote(:attachment_file, id: 1)
        FakeWeb.register_uri(:put, %r|/attachment_files/1.json|, :body => FactoryGirl.build(:attachment_file).to_json, :status => ["201", "Created"])
        FactoryGirl.remote(:specimen, id: 1)
        FakeWeb.register_uri(:put, %r|/specimens/1.json|, :body => FactoryGirl.build(:specimen).to_json, :status => ["201", "Created"])
      end
      it "calls update" do
        #allow(obj).to receive(:update)
        obj.affine_matrix_in_string = "[1,0,0;0,1,0;0,0,1]"
        p obj.encode
        obj2.save
        expect(FakeWeb).to have_requested(:put, %r|/specimens/1.json|)
        p FakeWeb.last_request.body
      end
    end

    describe "#post_multipart_form_data" do
      let(:obj){ AttachmentFile.new(:file => upload_file, :filename => 'example.txt')}
      let(:upload_file){ 'tmp/upload.txt' }
      before do
        setup_empty_dir('tmp')
        setup_file(upload_file)
        obj
        data = obj.to_multipart_form_data
        FakeWeb.register_uri(:post, %r|/attachment_files.json|, :body => FactoryGirl.build(:attachment_file).to_json, :status => ["201", "Created"])        
        obj.post_multipart_form_data(data)
      end
      it { expect(FakeWeb).to have_requested(:post, %r|/attachment_files.json|) }

    end

      #data = make_post_data(boundary,self.class.element_name,self.attributes)
      describe ".get_content_type" do
        let(:extname) { File.extname(filepath) }
        let(:filepath){ 'upload.txt' }
        it { expect(AttachmentFile.get_content_type_from_extname(extname)).to eq('text/plain') }
      end

    describe ".upload" do
      let(:upload_file){ 'tmp/test_image.jpg' }
      let(:geo_file){ 'tmp/test_image.geo' }
      before do
        setup_empty_dir('tmp')
        setup_file(upload_file)
        FakeWeb.register_uri(:post, %r|/attachment_files.json|, :body => FactoryGirl.build(:attachment_file).to_json, :status => ["201", "Created"])
        AttachmentFile.upload(upload_file, :filename => 'example.txt')
      end
      it { expect(FakeWeb).to have_requested(:post, %r|/attachment_files.json|) }
      context "with geofile" do
        before do
          setup_file(geo_file)
          AttachmentFile.upload(upload_file, :filename => 'example.txt')
        end
        it { expect(FakeWeb).to have_requested(:post, %r|/attachment_files.json|) }
      end

      context "with geofile specified in options" do
        before do
          setup_file(geo_file)
          AttachmentFile.upload(upload_file, :filename => 'example.txt', :geo_path => 'tmp/example.geo')
        end
        it { expect(FakeWeb).to have_requested(:post, %r|/attachment_files.json|) }
      end
    end

    describe "#length" do
      subject{ obj.length }
      let(:obj){ AttachmentFile.new(:original_geometry => "#{width}x#{height}")}
      let(:width){ 1947 }
      let(:height){ 1537 }
      it {
        expect(subject).to be_eql(width)
      }
    end

    describe "#height" do
      subject{ obj.height }
      let(:obj){ AttachmentFile.new(:original_geometry => "#{width}x#{height}")}
      let(:width){ 1947 }
      let(:height){ 1537 }
      it {
        expect(subject).to be_eql(height)
      }
    end

    describe "#width" do
      subject{ obj.width }
      let(:obj){ AttachmentFile.new(:original_geometry => "#{width}x#{height}")}
      let(:width){ 1947 }
      let(:height){ 1537 }
      it {
        expect(subject).to be_eql(width)
      }
    end

  end
end
