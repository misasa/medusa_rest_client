require 'spec_helper'

RSpec.describe 'Medusa HTTP transport' do
  let(:site) { 'http://app_development:3000/stone' }
  let(:credentials) { ['dream.misasa', 'password'] }

  it 'authenticates requests and loads UTF-8 resource attributes' do
    request = stub_request(:get, "#{site}/specimens/12.json").
      with(basic_auth: credentials, headers: { 'Accept' => 'application/json' }).
      to_return(status: 200, body: { id: 12, name: '試料 α' }.to_json)

    specimen = MedusaRestClient::Specimen.find(12)

    expect(specimen.id).to eq(12)
    expect(specimen.name).to eq('試料 α')
    expect(request).to have_been_requested.once
  end

  { 401 => ActiveResource::UnauthorizedAccess, 404 => ActiveResource::ResourceNotFound }.each do |status, error|
    it "preserves the API error for HTTP #{status}" do
      stub_request(:get, "#{site}/specimens/12.json").to_return(status: status)
      expect { MedusaRestClient::Specimen.find(12) }.to raise_error(error)
    end
  end

  it 'escapes parameters in nested resource paths' do
    expect(MedusaRestClient::Chemistry.element_path(7, analysis_id: 'analysis 12')).
      to eq('/stone/analyses/analysis%2012/chemistries/7.json')
  end

  [[], ['a', [], ['b', nil]]].each do |value|
    it "preserves multipart separators for array-valued metadata #{value.inspect}" do
      resource = MedusaRestClient::AttachmentFile.new(tags: value)
      expected = [
        '--3948A8',
        'Content-disposition: form-data; name="attachment_file[tags]"',
        '', value
      ].join("\r\n").b

      expect(resource.to_multipart_form_data).to eq(expected)
    end
  end

  [:post, :put].each do |method|
    it "uses the byte count for a UTF-8 multipart #{method.to_s.upcase} body" do
      data = "--test-boundary\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\n画像\r\n--test-boundary--"
      sent = nil
      stub_request(method, "#{site}/attachment_files/12.json").
        with { |request| sent = request; true }.
        to_return(status: 200, body: { id: 12 }.to_json)
      attachment = MedusaRestClient::AttachmentFile.new({ id: 12 }, true)

      attachment.public_send("#{method}_multipart_form_data", data, '/stone/attachment_files/12.json')

      expect(sent.headers['Content-Length'].to_i).to eq(data.bytesize)
      expect(sent.body).to eq(data)
    end

    it "preserves binary image bytes and UTF-8 metadata in multipart #{method.to_s.upcase}" do
      image_path = File.expand_path('../fixtures/files/test_image.jpg', __dir__)
      path = method == :post ? 'attachment_files.json' : 'attachment_files/12.json'
      sent = nil
      request = stub_request(method, "#{site}/#{path}").with(basic_auth: credentials).
        with { |req| sent = req; true }.
        to_return(status: method == :post ? 201 : 200,
                  headers: { 'Content-Type' => 'application/json' },
                  body: { id: 12, name: '顕微鏡画像' }.to_json)

      if method == :post
        attachment = MedusaRestClient::AttachmentFile.upload(image_path, name: '顕微鏡画像', filename: '試料.jpg')
      else
        attachment = MedusaRestClient::AttachmentFile.new({ id: 12, name: '顕微鏡画像' }, true)
        attachment.update_file(image_path, filename: '試料.jpg')
      end

      expect(request).to have_been_requested.once
      expect(attachment.id).to eq(12)
      expect(sent.body.b.include?(File.binread(image_path))).to be(true)
      expect(sent.body.b.include?('顕微鏡画像'.b)).to be(true)
      expect(sent.body.b.include?('filename="試料.jpg"'.b)).to be(true)
      expect(sent.body).to end_with('--3948A8--')
      expect(sent.headers['Content-Type']).to eq('multipart/form-data; boundary=3948A8')
      expect(sent.headers['Content-Length'].to_i).to eq(sent.body.bytesize)
    end
  end
end
