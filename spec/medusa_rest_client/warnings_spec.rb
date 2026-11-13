require 'open3'
require 'rbconfig'
require 'tmpdir'

# Exercise warning dispatch in a subprocess: a recursive Warning#warn can
# exhaust the stack before an in-process assertion can report the failure.
RSpec.describe 'MedusaRestClient warning handling' do
  def warning_output(message)
    library = File.expand_path('../../lib', __dir__)
    Dir.mktmpdir('medusa-warning-spec-') do |directory|
      File.write(File.join(directory, '.orochirc'),
                 "uri: https://medusa.invalid/\nuser: test\npassword: test\n")
      Open3.capture3(RbConfig.ruby, '-I', library, '-e',
                    "require 'medusa_rest_client'; warn ARGV.fetch(0)",
                    message, chdir: directory)
    end
  end

  it 'writes ordinary warnings without recursively calling Kernel#warn' do
    stdout, stderr, status = warning_output('ordinary warning')

    expect(status.success?).to be(true), stderr
    expect(stdout).to eq('')
    expect(stderr).to eq("ordinary warning\n")
  end

  it 'preserves the existing suppression of gem warnings' do
    stdout, stderr, status = warning_output('gems warning')

    expect(status.success?).to be(true), stderr
    expect(stdout).to eq('')
    expect(stderr).to eq('')
  end
end
