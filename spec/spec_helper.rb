require 'medusa_rest_client'
require 'factory_girl'
require 'fakeweb'
require 'fakeweb_matcher'
#require 'simplecov'
#require 'simplecov-rcov'
#SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
#SimpleCov.start


module FactoryGirl
  class RemoteStrategy
      def initialize
        @strategy = FactoryGirl.strategy_by_name(:build).new
      end

      delegate :association, to: :@strategy

      def result(evaluation)
        @strategy.result(evaluation).tap do |e|
          FakeWeb.register_uri(:get, self.class.entity_url(e), body: self.class.entity_hash(e).to_json)
          FakeWeb.register_uri(:put, self.class.entity_url(e), body: self.class.entity_hash(e).to_json)
          remote_search(e, search: { :"#{e.class.primary_key}_eq" => e.public_send(e.class.primary_key) })
          remote_search(e, search: { :"#{e.class.primary_key}_in" => [e.public_send(e.class.primary_key)] })
          evaluation.notify(:after_remote, e) # runs after(:remote) callback
        end
      end

      class << self
        def entity_hash(entity)
          raise ArgumentError, "cann't construct hash for non ActiveResource::Base object" unless entity.is_a?(ActiveResource::Base)
          attributes = entity.attributes
          # Set belongs_to <association>_id instead of each <association>.
          attributes.select { |k, v| v.is_a?(ActiveResource::Base) }.each do |k, v|
            attributes[:"#{k}_id"] = v.id
            attributes.delete(k)
          end
          # Set has_many <association> instead of each <association(s)>_ids.
          attributes.map do |k, v|
            next unless k.to_s =~ /^(\w+)_ids$/ && FactoryGirl.factories.map(&:name).include?(f = $1.singularize.to_sym) && v.is_a?(Array)
            [k, v, f, $1.pluralize.to_sym]
          end.compact.each do |k, v, f, r|
            attributes[r] = v.map { |id| FactoryGirl.remote(f, id: id) }
            attributes.delete(k)
          end
          # Serilaize has_many associations.
          attributes.each do |k, v|
            if v.is_a?(Array) && v.first.is_a?(ActiveResource::Base)
              attributes[k] = v.map { |e| entity_hash(e) }
            end
          end
          #{ entity.class.element_name => attributes, _metadata: { abilities: %w(update destroy) } }
          attributes          
        end

        def entity_url(entity)
          "#{entity.class.site_with_userinfo}#{entity.class.prefix}#{entity.class.collection_name}/#{entity.id}.json"
        end

        def collection_url(collection)
          (collection.first.is_a?(Class) ? collection.first : collection.first.class).instance_eval { "#{site_with_userinfo}#{prefix}#{collection_name}.json" }
        end
      end
  end
end

FactoryGirl.register_strategy(:remote, FactoryGirl::RemoteStrategy)
def remote_search(*args)
  params = args.extract_options!
  collection = args.flatten
  FakeWeb.register_uri(:get, "#{FactoryGirl::RemoteStrategy.collection_url(collection)}?#{params.to_query}",
    body: (collection.first.is_a?(Class) ? "[]" : collection.map { |e| FactoryGirl::RemoteStrategy.entity_hash(e) }.to_json))
end


Dir.glob("spec/support/**/*.rb") { |f| load f, true }


FakeWeb.allow_net_connect = false

include MedusaRestClient
FactoryGirl.find_definitions
Dir.glob("spec/steps/**/*steps.rb") { |f| load f, true }

def setup
  MedusaRestClient::Base.site = "http://app:3002"
  MedusaRestClient::Base.prefix = "/"
  MedusaRestClient::Base.user = "dream.misasa"
  MedusaRestClient::Base.password = "password"
  MedusaRestClient::Base.logger = Logger.new(STDOUT)
  MedusaRestClient::Base.logger.level = Logger::DEBUG 
end

def setup_header
  {"Authorization" => 'Basic '+Base64.encode64("#{MedusaRestClient::Base.user}:#{MedusaRestClient::Base.password}").gsub(/\n/,''), 'Accept' => 'application/json'}
end

def deleteall(delthem)
  if FileTest.directory?(delthem) then
    Dir.foreach( delthem ) do |file|
      next if /^\.+$/ =~ file
      deleteall(delthem.sub(/\/+$/,"") + "/" + file)
    end
    #p "#{delthem} deleting..."   
    Dir.rmdir(delthem) rescue ""
  else
    #p "#{delthem} deleting..."
    File.delete(delthem)
  end
end

def setup_empty_dir(dirname)
  deleteall(dirname) if File.directory?(dirname)
  FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
end


def setup_file(destfile)
  src_dir = File.expand_path('../fixtures/files',__FILE__)
  filename = File.basename(destfile)
  dest_dir = File.dirname(destfile)
  dest = File.join(dest_dir, filename)
  src = File.join(src_dir, filename)
  FileUtils.mkdir_p(dest_dir) unless File.directory?(dest_dir)
  FileUtils.copy(src, dest)
end


def setup_data(destdir)
  src_dir = File.expand_path('../fixtures/VS2007data',__FILE__)
  basename = File.basename(destdir)
  dest_dir = File.dirname(destdir)
  src = File.join(src_dir, basename)
  FileUtils.mkdir_p(dest_dir) unless File.directory?(dest_dir)
  FileUtils.cp_r(src, dest_dir)
end

def filename_for(path, opts = {})
  extname = File.extname(path).sub(/\./,'')
  if opts[:ext]
    extname = opts[:ext].to_s
  end
  dirname = File.dirname(path)
  dirname = File.join(dirname,opts[:insert_path]) if opts[:insert_path]
  File.join(dirname, File.basename(path, ".*") + ".#{extname}")
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.deprecation_stream = 'log/deprecations.log'
end
