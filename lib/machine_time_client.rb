require "machine_time_client/version"
#require 'machine_time_client/machine'
#require 'machine_time_client/session'
require 'yaml'

module MachineTimeClient
	@default_machine = 'MACHINE-1'
	@default_uri = 'http://database.misasa.okayama-u.ac.jp/machine/'
	DEFAULT_CONFIG = {:uri_machine => @default_uri, :machine => @default_machine }

  	@pref_path = nil
	def self.pref_path=(pref_path) @pref_path = pref_path end
	def self.pref_path
		@pref_path ||= "~/.godigorc"
#		@pref_path ||= "~/.orochirc"
	end

	@config = nil
	def self.config=(config)
		@config = config
	end

	def self.config
		load_config unless @config
		@config
	end

	def self.load_config
		begin
			self.config = self.read_config
		rescue
			self.config = DEFAULT_CONFIG
			self.write_config
		end		
  	end

	def self.read_config
	  	raise("Orochi configuration file is missing in |#{pref_path}|.  Install properly.") if !File.exist?(File.expand_path(pref_path))
		config = YAML.load(File.read(File.expand_path(pref_path)))
	end

	def self.write_config
		config = Hash.new
		config = self.config
		STDERR.puts("writing |#{File.expand_path(self.pref_path)}|")
		open(File.expand_path(self.pref_path), "w") do |f|
			YAML.dump(config, f)
		end
	end  	

  	def self.default_machine
  		if config.has_key?(:machine)
  		  	config[:machine]
  		else
  			@default_machine
  		end
  	end

  	def self.site
  		uri.scheme + '://' + uri.host + (uri.port ? ":#{uri.port}" : "")
  	end

  	def self.prefix
		uri.path
	end

	def self.uri
		uri_string = @default_uri
		if config.has_key?(:uri_machine)
			uri_string = config[:uri_machine]
		elsif config.has_key?('uri_machine')
			uri_string = config['uri_machine']
		else
			raise "Orochi configuration file |#{pref_path}| does not have parameter |uri_machine|.  Put a line such like |uri_machine: #{@default_uri}|."
		end
		uri_string = "http://" + uri_string unless (/:\/\// =~ uri_string)
		uri_string = uri_string + "/" unless (/\/\z/ =~ uri_string)
		URI.parse(uri_string)
	end

	def self.machine_name
		if config.has_key?(:machine)
			name = config[:machine]
		elsif config.has_key?('machine')
			name = config['machine']
		else
			raise "Orochi configuration file |#{pref_path}| does not have parameter |machine|.  Put a line such like |machine: #{@default_machine}|."
		end

		name
	end
  # Your code goes here...
require 'machine_time_client/machine'
require 'machine_time_client/session'
ActiveResource::Base.logger = Logger.new($stderr)

end
