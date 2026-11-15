# Run under Bundler. Install only this archive; reuse precisely resolved dependencies.
require 'bundler'
require 'rubygems/package'
require 'rbconfig'
require 'open3'
require 'tmpdir'
require 'fileutils'
require 'digest'
require_relative '../lib/medusa_rest_client/version'

root = File.expand_path('..', __dir__)
archive = File.expand_path(ARGV.fetch(0))
package = Gem::Package.new(archive)
raise 'Invalid gem archive' unless package.verify
spec = package.spec
raise 'Package version differs from source' unless spec.version.to_s == MedusaRestClient::VERSION
raise 'Wrong package name' unless spec.name == 'medusa_rest_client'
expected_files = Dir.chdir(root) { %w[README.md LICENSE.txt bin/medusa] + Dir['lib/**/*.rb'] }
raise 'Unexpected or missing packaged files' unless package.contents.sort == expected_files.sort
raise 'Wrong executable metadata' unless spec.executables == ['medusa']
raise 'Wrong license metadata' unless spec.licenses == ['GPL-3.0-or-later']
raise 'Wrong Ruby floor' unless spec.required_ruby_version.to_s == '>= 2.5.0'

# A new gem home contains only the resolved dependency versions. No access to
# unrelated installed gems, and no download or change to the user's gem home.
resolved = Bundler.load.specs.to_a
names = spec.runtime_dependencies.map(&:name)
dependencies = []
until names.empty?
  name = names.shift
  next if dependencies.any? { |dependency| dependency.name == name }
  dependency = resolved.find { |candidate| candidate.name == name }
  raise "Missing resolved runtime dependency: #{name}" unless dependency
  dependencies << dependency
  names.concat(dependency.runtime_dependencies.map(&:name))
end
Dir.mktmpdir('medusa_rest_client-package-') do |directory|
  extracted = File.join(directory, 'archive')
  package.extract_files(extracted)
  expected_files.each do |path|
    raise "Archive differs from source: #{path}" unless Digest::SHA256.file(File.join(extracted, path)).hexdigest == Digest::SHA256.file(File.join(root, path)).hexdigest
  end
  home = File.join(directory, 'gems')
  FileUtils.mkdir_p([File.join(home, 'gems'), File.join(home, 'specifications')])
  dependencies.each do |dependency|
    FileUtils.ln_s(dependency.full_gem_path, File.join(home, 'gems', dependency.full_name))
    File.write(File.join(home, 'specifications', "#{dependency.full_name}.gemspec"), dependency.to_ruby)
    if dependency.extensions.any?
      target = File.join(home, 'extensions', Gem::Platform.local.to_s, Gem.extension_api_version, dependency.full_name)
      FileUtils.mkdir_p(File.dirname(target))
      FileUtils.ln_s(dependency.extension_dir, target)
    end
  end

  File.write(File.join(directory, '.orochirc'), "---\nuri: https://medusa.invalid/\nuser: test\npassword: test\n")
  environment = {'HOME' => directory, 'GEM_HOME' => home, 'GEM_PATH' => home, 'RUBYLIB' => nil, 'RUBYOPT' => nil}
  execute = lambda do |*arguments|
    stdout, stderr, status = Open3.capture3(environment, RbConfig.ruby, *arguments, chdir: directory)
    raise "Command failed (#{status.exitstatus}): #{arguments.inspect}\n#{stdout}\n#{stderr}" unless status.success?
    stdout
  end
  Bundler.with_unbundled_env do
    execute.call('-rrubygems/gem_runner', '-e', 'Gem::GemRunner.new.run(ARGV)', '--',
                 'install', '--local', '--no-document', '--ignore-dependencies', archive)
    check = <<~'RUBY'
      require 'medusa_rest_client'
      spec = Gem.loaded_specs.fetch('medusa_rest_client')
      abort 'Wrong installed version' unless MedusaRestClient::VERSION == ARGV.fetch(0)
      abort 'Wrong installation directory' unless File.realpath(spec.base_dir) == File.realpath(ENV.fetch('GEM_HOME'))
      feature = $LOADED_FEATURES.find { |path| path.end_with?('/lib/medusa_rest_client.rb') }
      abort 'Loaded source instead of installed gem' unless feature == File.join(spec.full_gem_path, 'lib/medusa_rest_client.rb')
      specimen = MedusaRestClient::Specimen.new(id: 12, name: 'Installed specimen')
      abort 'Installed resource failed' unless specimen.name == 'Installed specimen'
      abort 'Installed route failed' unless MedusaRestClient::Specimen.element_path(12) == '/specimens/12.json'
      puts MedusaRestClient::VERSION
    RUBY
    execute.call('-e', check, MedusaRestClient::VERSION)
    executable = File.join(home, 'bin', 'medusa')
    [[], ['upload'], ['remove'], ['console']].each do |args|
      output = execute.call(executable, *args, '--help')
      raise 'Missing installed CLI help' unless output.include?('Usage: medusa')
    end
    raise 'Missing version output' unless execute.call(executable, '--version').include?(MedusaRestClient::VERSION)
  end
end
puts "Verified archive and installed CLI: #{File.basename(archive)} (Ruby #{RUBY_VERSION})"
