module MedusaRestClient
  class Base < ActiveResource::Base
    self.site = MedusaRestClient.site
    self.prefix = MedusaRestClient.prefix
    self.user = MedusaRestClient.user
    self.password = MedusaRestClient.password

    @@boundary = "3948A8"
    def self.init(opts = {})
      @@pwd_id = ENV['OROCHI_PWD'] || nil
      @@home_id = ENV['OROCHI_HOME'] || nil   
    end

    def self.site_with_userinfo
      return self.site if !self.user || !self.password
      uri = self.site.dup
      uri.userinfo = [self.user, self.password]
      uri
    end

    def self.content_types
      {
          ".pdf" => "application/pdf",
          ".txt" => "text/plain",
          ".tex" => "text/plain",        
          ".gif" => "image/gif",
          ".jpg" => "image/jpeg",
          ".JPG" => "image/jpeg",
          ".jpeg" => "image/jpeg",
          ".png"=> "image/png",
          ".flv" => "video/x-flv",
          ".wmv" => "video/x-ms-wmv"
          }           
    end

    def self.default_content_type
      "application/octet-stream"
    end

    def self.get_content_type_from_extname(extname)
      #content_types.fetch(extname)
      content_types[extname]
    end

    def self.mycleanpath(path)
      path = Pathname.new(path)
      unless path.absolute?
        path = Pathname.new(self.pwd) + path
      end
      path = path.cleanpath
    end

    def self.find_by_name(name)
      self.find(:all, :params => {:q => {:name_cont => name}})
    end

    def self.search(params = {})
      self.find(:all, :params => {:q => params})
    end

    def post_multipart_form_data(data, post_path = collection_path)
      raise "could not find boundary" unless md = data.match(/^--(.*)\r\n/)
      boundary = md[1]
      header ={
            'Content-Length' => data.length.to_s,
            'Content-Type' => "multipart/form-data; boundary=#{boundary}",
            'Accept' => 'application/json'
          }
      connection.post(post_path, data, header).tap do |response|
        self.id = id_from_response(response)
        return load_attributes_from_response(response)
      end     
    end


    def put_multipart_form_data(data, put_path = element_path)
      raise "could not find boundary" unless md = data.match(/^--(.*)\r\n/)
      boundary = md[1]
      header ={
            'Content-Length' => data.length.to_s,
            'Content-Type' => "multipart/form-data; boundary=#{boundary}",
            'Accept' => 'application/json'
          }
      connection.put(put_path, data, header).tap do |response|
        self.id = id_from_response(response)
        return load_attributes_from_response(response)
      end     
    end
    #def self.element_path_with_format_extension(id, prefix_options = {}, query_options = nil)
    # check_prefix_options(prefix_options)
    # prefix_options, query_options = split_options(prefix_options) if query_options.nil?
    # "#{prefix(prefix_options)}#{collection_name}/#{URI.parser.escape id.to_s}#{query_string(query_options)}"
    #end


    def self.download_single(scope, options)
      prefix_options, query_options = split_options(options[:params])
      path = element_path(scope, prefix_options, query_options)
      basename = File.basename(path)
      File.open(basename, 'wb') {|f|
        f.puts connection.get(path, headers).body
      }
    end

    def self.download_one(options)
      content = nil
      case from = options[:from]
        when Symbol
          content = get(from, options[:params])
        when String
          path = "#{from}#{query_string(options[:params])}"
          content = connection.get(path, headers).body
      end
      content
    end


    def upload_file(opts = {})
      raise "specify :file" unless opts[:file]
      #file = AttachmentFile.new(:file => opts[:file])
      file = AttachmentFile.new(opts)
      #filepath = opts[:file]
      prefix = self.class.prefix
      collection_name = self.class.collection_name + '/' + self.id.to_s + '/' + AttachmentFile.collection_name
      format_extension = self.class.format_extension
          upload_path = "#{prefix}#{collection_name}#{format_extension}"
          file.post_multipart_form_data(file.to_multipart_form_data(opts), upload_path)
          return file
      #attachment_file = AttachmentFile.upload()
    end

    def upload_image(opts = {})
      raise "specify :file" unless opts[:file]
      file = AttachmentFile.new(opts)
      prefix = self.class.prefix
      collection_name = self.class.collection_name + '/' + self.id.to_s + '/images'
      format_extension = self.class.format_extension
          upload_path = "#{prefix}#{collection_name}#{format_extension}"
          file.post_multipart_form_data(file.to_multipart_form_data(opts), upload_path)
          return file
    end

    def to_multipart_form_data(opts = {})
      boundary = opts[:boundary] || @@boundary
      model = opts[:model] || self.class.element_name
      path = attributes.delete('file')
      data = []
      attributes.each do |key , value|
        unless key == 'file'
          data << "--#{boundary}"
          data << "Content-disposition: form-data; name=\"#{model}[#{key}]\""
          data << ""
          data << value
        end
      end
      if path
        if opts[:geo_path]
          geo_path = opts[:geo_path]
        else
          dirname = File.dirname(path)
          basename = File.basename(path,".*")
          geo_path = File.join(dirname,basename + ".geo")
        end
        if File.file?(geo_path)
          if corners_on_world_in_string = AttachmentFile.get_corners_on_world_from_geo(geo_path)
            data << "--#{boundary}"
            data << "Content-disposition: form-data; name=\"#{model}[corners_on_world_in_string]\""
            data << ""
            data << corners_on_world_in_string
          elsif affine_matrix_in_string = AttachmentFile.get_affine_from_geo(geo_path)
          #if affine_matrix_in_string
            data << "--#{boundary}"
            data << "Content-disposition: form-data; name=\"#{model}[affine_matrix_in_string]\""
            data << ""
            data << affine_matrix_in_string
            #data << AttachmentFile.get_affine_from_geo(geo_path)
          end
        end

        filename = attributes.delete('filename') || File.basename(path)

        content_type = self.class.get_content_type_from_extname(File.extname(filename)) || self.class.default_content_type      
        data << "--#{boundary}"
        data << "Content-Disposition: form-data; name=\"#{model}[data]\"; filename=\"#{filename}\""
        data << "Content-Type: #{content_type}"
        data << ""
        data << File.open(path){|file|
          file.binmode
          file.read
        }
        data << "--#{boundary}--"
      end
      data.join("\r\n")
    end

    def self.find_or_create_by_name(name, params = {})
      obj = self.find(:first, :params => {:q => {:name_eq => name}})
      unless obj
        params.merge!(:name => name)
        obj = self.create(params)
      end
      obj
    end

    #associations
    def record_property
            self.get(:record_property)
    end

    def update_global_id(id)
      update_record_property(:global_id => id)
    end

                def is_lost
                  record_property["lost"]
                end

                def is_disposed
                  record_property["disposed"]
                end

                def lose
                  change_status('lose')
                end
    
                def found
                  change_status('found')
                end

                def change_status(action)
      prefix = self.class.prefix
      collection_name = self.class.collection_name + '/' + self.id.to_s + "/record_property/#{action}"
      format_extension = self.class.format_extension
            update_path = "#{prefix}#{collection_name}#{format_extension}"
      connection.put(update_path, self.send("to_#{self.class.format.extension}"), self.class.headers)
                end

    def update_record_property(record_property)
      prefix = self.class.prefix
      collection_name = self.class.collection_name + '/' + self.id.to_s + '/record_property'
      format_extension = self.class.format_extension
          update_path = "#{prefix}#{collection_name}#{format_extension}"
      connection.put(update_path, record_property.send("to_#{self.class.format.extension}"), self.class.headers)
    end

    def parent
      p_id = self.attributes["parent_id"]
      return unless p_id
      self.class.find(p_id)
    end

    def box
      p_id = self.attributes["box_id"]
      return unless p_id
      Box.find(p_id)  
    end

    def stone
      p_id = self.attributes["specimen_id"]
      return unless p_id
      Specimen.find(p_id)
    end

    def specimen
      p_id = self.attributes["specimen_id"]
      return unless p_id
      Specimen.find(p_id)
    end

    def place
      p_id = self.attributes["place_id"]
      return unless p_id
      Place.find(p_id)
    end

    def attachment_file
      p_id = self.attributes["attachment_file_id"]
      return unless p_id
      AttachmentFile.find(p_id)
    end

    def relatives
      MyAssociation.new(self)
    end

    def boxes
      MyAssociation.new(self, Box)      
    end

    def stones
      MyAssociation.new(self, Specimen)
    end

    def specimens
      MyAssociation.new(self, Specimen)
    end

    def attachment_files
      MyAssociation.new(self, AttachmentFile)     
    end
    
    #def images
    #  MyAssociation.new(self, Image)
    #end

    def bibs
      MyAssociation.new(self, Bib)      
    end

    def analyses
      MyAssociation.new(self, Analysis)
    end

    def spots
      MyAssociation.new(self, Spot)     
    end

    def tables
      MyAssociation.new(self, Table)
    end

  end
end
