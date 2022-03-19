module MedusaRestClient
  class AttachmentFile < Base

    def self.find_by_file(filepath)
      md5hash = Digest::MD5.hexdigest(File.open(filepath, 'rb').read)
      self.find(:first, :params => {:q => {:md5hash_eq => md5hash}} )
    end

    def self.find_or_create_by_file(filepath)
      mi = self.find_by_file(filepath)
      return mi if mi
      mi = self.new(:file => filepath)
      mi.save
      mi
    end

    def self.upload(filepath, opts = {})
      raise "#{filepath} does not exist" unless File.exists?(filepath)
      obj = AttachmentFile.create(opts.merge(:file => filepath))
      obj
    end

    def update_affine_matrix(affine_matrix = [1,0,0,0,1,0,0,0,1])

      put(:update_affine_matrix,{}, ActiveSupport::JSON.encode({affine_matrix: affine_matrix}))
    end

    def update_corners(corners_on_world = {lu:[-50,33.4375], ru:[50.0, 33.4375], rb:[50.0, -33.4375], lb:[-50.0, -33.4375]})
      put(:update_corners,{}, ActiveSupport::JSON.encode(attachment_file: self.attributes, corners_on_world: corners_on_world))
    end

    def update_file(filepath, opts = {})
      raise "#{filepath} does not exist" unless File.exists?(filepath)
      self.file = filepath
      self.filename = opts[:filename] if opts[:filename]
      self.geo_path = opts[:geo_path] if opts[:geo_path]
      data = to_multipart_form_data(opts)
      put_multipart_form_data(data)
    end

    def self.get_affine_from_geo(filepath, opts = {})
      if File.file?(filepath)
        geo = YAML.load_file(filepath)
        if geo.has_key?("affine_xy2vs") || geo.has_key?("imageometry")
          affine_xy2vs = geo["affine_xy2vs"] || geo["imageometry"]
          if affine_xy2vs.is_a?(Array)
            array = affine_xy2vs
            affine_matrix_in_string = "[#{array.map{|a| a.join(', ')}.join(';')}]"
          else
            affine_matrix_in_string = affine_xy2vs
          end
          return affine_matrix_in_string
        end
      end
    end

    def dump_geofile(filepath, opts = {})
      #a,b,c,d,e,f,g,h,i = self.affine_matrix
      geo = Hash.new
      #geo['affine_xy2vs'] = [[a,b,c],[d,e,f],[g,h,i]]
      geo['imageometry'] = self.affine_matrix_in_string
      YAML.dump(geo,File.open(filepath,'w'))
    end
      # def self.find_by_localfile(mylocalfile)
      #   md5hash = Digest::MD5.hexdigest(File.open(mylocalfile, 'rb').read)
      #   existings = Attachment.find(:all, :params => {:md5hash => md5hash})
      # end

      def length
        return unless width && height
        width >= height ? width : height
      end

      def width
        return unless original_geometry
        original_geometry =~ /(\d+)x/
        $1.to_i if $1
      end

      def height
        return unless original_geometry
        original_geometry =~ /x(\d+)/
        $1.to_i if $1
      end

      def save
        if new?
          #create_with_upload_data
          post_multipart_form_data(to_multipart_form_data(self.attributes))
        else
          update
        end
      end


      def create_spot(spot_params)
        spot = Spot.new(spot_params)
        spot.prefix_options[:attachment_file_id] = self.id
        spot.save
      end      
      # def create_with_upload_data
      #   boundary="-------------------3948A8"
      #   data = make_post_data(boundary,self.class.element_name,self.attributes)

      #   header ={
      #     'Content-Length' => data.length.to_s,
      #     'Content-Type' => "multipart/form-data; boundary=#{boundary}",
      #     'Accept' => 'application/json'
      #   }

      #   connection.post(collection_path, data, header).tap do |response|
      #     self.id = id_from_response(response)
      #     return load_attributes_from_response(response)
      #   end

      # end

      # def make_post_data(boundary, model, post_data={})
      #   type = {
      #     ".pdf" => "application/pdf",
      #     ".txt" => "text/plain",
      #     ".tex" => "text/plain",        
      #     ".gif" => "image/gif",
      #     ".jpg" => "image/jpeg",
      #     ".JPG" => "image/jpeg",
      #     ".jpeg" => "image/jpeg",
      #     ".png"=> "image/png",
      #     ".flv" => "video/x-flv",
      #     ".wmv" => "video/x-ms-wmv"
      #   }
      #   data = ""
      #   post_data.each do |key , value|
      #     unless key == 'file'
      #       data << %[--#{boundary}\r\n]
      #       data << %[Content-disposition: form-data; name="#{model}[#{key}]"\r\n]
      #       data << "\r\n"
      #       data << "#{value}\r\n"
      #     end
      #   end

      #   path = post_data['file']
      #   if path
      #     data << %[--#{boundary}] + "\r\n"
      #     data << %[Content-Disposition: form-data; name="#{model}[data]"; filename="#{File.basename(path)}"] + "\r\n"
      #     data << "Content-Type: #{type.fetch(File.extname(path))}" + "\r\n\r\n"
      #     # data << "Content-Transfer-Encoding: binary\r\n"
      #     #data << File.read(path)
      #     data << File.open(path){|file|
      #       file.binmode
      #       file.read
      #     }
      #   end
      #   data << %[\r\n--#{boundary}--\r\n]
      #   data
      # end

  end
end
