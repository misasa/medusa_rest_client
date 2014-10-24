require "active_resource"
require "machine_time_client"
require 'machine_time_client/session'
module MachineTimeClient
  class Machine < ActiveResource::Base
  	self.site = MachineTimeClient.site
  	self.prefix = MachineTimeClient.prefix

  	def self.action_path(id, action, prefix_options = {}, query_options = nil)
  		check_prefix_options(prefix_options)
  		prefix_options, query_options = split_options(prefix_options) if query_options.nil?
  		"#{prefix(prefix_options)}#{collection_name}/#{URI.parser.escape id.to_s}/#{action}#{format_extension}#{query_string(query_options)}"
  	end

  	def action_path(action, options = nil)
		self.class.action_path(to_param, action, options || prefix_options)
  	end

	# Start the resource on the remote service.
	def start
		run_callbacks :update do
			connection.put(action_path('start', prefix_options), encode, self.class.headers)
		end
	end

	# Stop the resource on the remote service.
	def stop
		run_callbacks :update do
			connection.put(action_path('stop', prefix_options), encode, self.class.headers)
		end
	end

	def current_session
		Session.find(:one, :from => action_path('current_session', prefix_options))
	end

  end
end
