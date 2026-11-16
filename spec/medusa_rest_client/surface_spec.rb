require 'spec_helper'

module MedusaRestClient
  describe Surface do
    describe ".find" do
      subject { Surface.find(:all) }
      before do
        stub_request(:get, %r|/surfaces.json|).to_return(:body => [].to_json, :status => ["200", "OK"])
        subject
      end
      it { expect(WebMock).to have_requested(:get, %r|/surfaces.json|) }
    end


    describe "#upload_file" do
      let(:upload_file){ 'tmp/test_image.jpg' }
      before do
        setup_empty_dir('tmp')
        setup_file(upload_file)
        surface = FactoryBot.build(:surface, id: 10)
        stub_request(:post, %r|/surfaces/10/images.json|).to_return(:body => FactoryBot.build(:attachment_file).to_json, :status => ["201", "Created"])
        surface.upload_image(:file => upload_file, :filename => 'example.jpg')
      end
      it { expect(WebMock).to have_requested(:post, %r|/surfaces/10/images.json|) }
    end

    describe "#make_tiles" do
      before do
        surface = FactoryBot.build(:surface, id: 10)
        stub_request(:post, %r|/surfaces/10/tiles.json|).to_return(:body => nil, :status => ["201", "Created"])
        surface.make_tiles
      end
      it { expect(WebMock).to have_requested(:post, %r|/surfaces/10/tiles.json|) }
    end

    describe "#make_image_tiles" do
      before do
        surface = FactoryBot.build(:surface, id: 10)
        stub_request(:get, %r|/surfaces/10/images/55271.json|).to_return(:body => FactoryBot.build(:surface_image, surface_id:10, image_id:55271).to_json, :status => ["200", "OK"])
        stub_request(:post, %r|/surfaces/10/images/55271/tiles.json|).to_return(:body => nil, :status => ["201", "Created"])
        surface.make_image_tiles(55271)
      end
      it { expect(WebMock).to have_requested(:post, %r|/surfaces/10/images/55271/tiles.json|) }
    end
    describe "#make_layer_tiles" do
      before do
        surface = FactoryBot.build(:surface, id: 10)
        stub_request(:post, %r|/surfaces/10/layers/20/tiles.json|).to_return(:body => nil, :status => ["201", "Created"])
        surface.make_layer_tiles(20)
      end
      it { expect(WebMock).to have_requested(:post, %r|/surfaces/10/layers/20/tiles.json|) }
    end
  end
end
