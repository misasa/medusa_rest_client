module MedusaRestClient
  VERSION = "0.2.0"
  class VersionInfo

    def jruby?
      ::JRUBY_VERSION if RUBY_PLATFORM == "java"
    end

    def engine
      defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'mri'
    end

    def warnings
      []
    end

    def to_hash
      hash_info = {}
      hash_info['warnings']       = []
      hash_info['medusa_rest_client']       = MedusaRestClient::VERSION
      hash_info['ruby']         = {}
      hash_info['ruby']['version']    = ::RUBY_VERSION
      hash_info['ruby']['platform']   = ::RUBY_PLATFORM
      hash_info['ruby']['description']  = ::RUBY_DESCRIPTION
      hash_info['ruby']['engine']     = engine
      hash_info['ruby']['jruby']      = jruby? if jruby?
      hash_info
    end

    def to_markdown
      begin
        require 'psych'
      rescue LoadError
      end
      require 'yaml'
      "# MedusaRestClient (#{MedusaRestClient::VERSION})\n" + 
      YAML.dump(to_hash).each_line.map {|line| "    #{line}" }.join
    end

    @@instance = new
    @@instance.warnings.each do |warning|
      warn "WARNING: #{warning}"
    end
    def self.instance; @@instance; end
  end
end
