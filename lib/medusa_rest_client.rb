require 'logger'
require 'active_resource'
require 'yaml'
require 'pathname'
require 'tempfile'

module Warning
  def warn(str)
    return if str.match?("gems")

    super
  end
end

module MedusaRestClient
  # Your code goes here...
  @pref_path = nil
  def self.pref_path=(pref_path)
    @pref_path = pref_path
  end
  def self.pref_path
    @pref_path ||= "~/.orochirc"
  end

  @default_uri = 'database.misasa.okayama-u.ac.jp/stone/'

  DEFAULT_CONFIG = {'uri' => @default_uri, 'user' => 'admin', 'password' => 'password'}

  @config = nil
  def self.config=(config) @config = config end
  def self.config
    load_config unless @config
    @config 
  end

  def self.load_config
    begin
      self.config = read_config
    rescue => ex
      self.config = DEFAULT_CONFIG
      self.write_config
    end
  end

  def self.read_config
    YAML.load(File.read(File.expand_path(pref_path)))
  end

  def self.write_config
    STDERR.puts("writing |#{File.expand_path(self.pref_path)}|")
    open(File.expand_path(self.pref_path), "w") do |f|
      YAML.dump(self.config, f)
    end
  end

  @uri = nil
  def self.uri=(uri)
    @uri = uri
  end
  def self.uri
    unless @uri
      if self.config.has_key?("uri")
        uri_string = self.config['uri']
      else
        uri_string = @default_uri
      end
      # uri_string = "http://" + uri_string unless (/:\/\// =~ uri_string)
      uri_string = "https://" + uri_string unless (/:\/\// =~ uri_string)
      uri_string = uri_string + "/" unless (/\/\z/ =~ uri_string)
      @uri = URI.parse(uri_string)
    end
    @uri
  end

  def self.site
    uri.scheme + '://' + uri.host + (uri.port ? ":#{uri.port}" : "")
  end
  def self.prefix
    uri.path
  end
  def self.user
      config['user']
  end
  def self.password
      config['password']
  end

end

require 'medusa_rest_client/version'
require 'medusa_rest_client/my_association'
require 'medusa_rest_client/base'
require 'medusa_rest_client/record'
require 'medusa_rest_client/specimen'
require 'medusa_rest_client/stone'
require 'medusa_rest_client/box'
require 'medusa_rest_client/box_root'
require 'medusa_rest_client/place'
require 'medusa_rest_client/analysis'
require 'medusa_rest_client/chemistry'
require 'medusa_rest_client/attachment_file'
require 'medusa_rest_client/image'
require 'medusa_rest_client/bib'
require 'medusa_rest_client/measurement_item'
require 'medusa_rest_client/device'
require 'medusa_rest_client/classification'
require 'medusa_rest_client/physical_form'
require 'medusa_rest_client/box_type'
require 'medusa_rest_client/measurement_category'
require 'medusa_rest_client/unit'
require 'medusa_rest_client/technique'
require 'medusa_rest_client/author'
require 'medusa_rest_client/spot'
require 'medusa_rest_client/surface'
require 'medusa_rest_client/surface_image'
require 'medusa_rest_client/surface_layer'
require 'medusa_rest_client/table'

module ActiveSupport
  Inflector.inflections do |inflect|
    inflect.irregular "specimen", "specimens"
  end
end


module ActiveResource # :nodoc:
  class Collection # :nodoc:
    def previous_page
      params = original_params.merge(:page => (original_params[:page] ? original_params[:page] - 1 : 2) )
      resource_class.find(:all, :params => params)      
    end

    def next_page
      params = original_params.merge(:page => (original_params[:page] ? original_params[:page] + 1 : 2) )
      resource_class.find(:all, :params => params)
    end
  end
end
