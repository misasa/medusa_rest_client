require 'spec_helper'
module MedusaRestClient

  describe SurfaceImage do
    before do
        setup
        WebMock.reset!
        ActiveResource::Base.logger = Logger.new(STDOUT)
        ActiveResource::Base.logger.level = Logger::DEBUG
    end

    describe "surface.images" do
      subject{ surface.images }
      let(:surface){ FactoryBot.remote(:surface, id: 2530) }
      before do
        stub_request(:get, %r|/surfaces/#{surface.id}/images.json|).to_return(:body => [].to_json, :status => ["200", ""])
        subject
      end

      it {
        expect(WebMock).to have_requested(:get, %r|/surfaces/#{surface.id}/images.json|)
      }
    end
  end
end