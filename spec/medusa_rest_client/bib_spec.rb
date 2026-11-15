require 'spec_helper'

module MedusaRestClient
  describe Bib do
    describe ".find" do
      subject { Bib.find(:all) }
      before do
        stub_request(:get, %r|/bibs.json|).to_return(:body => [].to_json, :status => ["200", "OK"])
        subject
      end
      #it { expect(subject).not_to raise_error }
      it { expect(WebMock).to have_requested(:get, %r|/bibs.json|) }

    end
  end
end
