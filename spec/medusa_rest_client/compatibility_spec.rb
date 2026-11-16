require 'spec_helper'
require 'open3'
require 'rbconfig'

RSpec.describe 'Ruby compatibility' do
  let(:file) { File.expand_path('../fixtures/files/upload.txt', __dir__) }

  it 'reports missing upload files clearly' do
    expect { MedusaRestClient::AttachmentFile.upload('missing-file') }.
      to raise_error(RuntimeError, 'missing-file does not exist')
  end

  it 'reports missing replacement files clearly' do
    attachment = MedusaRestClient::AttachmentFile.new(id: 12)
    expect { attachment.update_file('missing-file') }.
      to raise_error(RuntimeError, 'missing-file does not exist')
  end

  it 'updates an attachment with multipart file contents' do
    request = stub_request(:put, 'http://app_development:3000/stone/attachment_files/12.json').
      with { |req| req.body.include?(File.binread(file)) && req.body.include?('replacement.txt') }.
      to_return(status: 200, body: { id: 12 }.to_json)
    attachment = MedusaRestClient::AttachmentFile.new({ id: 12 }, true)
    attachment.update_file(file, filename: 'replacement.txt')
    expect(request).to have_been_requested
  end

  it 'runs console scripts with verbose output' do
    command = File.expand_path('../../bin/medusa', __dir__)
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, command, '--verbose', 'console', '-e', 'puts "console works"')
    expect(status.success?).to be(true), stderr
    expect(stdout).to include('console works')
  end
end
