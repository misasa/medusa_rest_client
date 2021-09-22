module MedusaRestClient
  class Surface < Base
    def self.new(attributes = {}, persisted = false)
      map_data = attributes.delete("map_data")
      super(attributes, persisted)
    end

    def to_json(options={})
      super({ :root => self.class.element_name }.merge(options))
    end

    def images(scope=:all)
      SurfaceImage.find(scope, :params => { :surface_id => id })      
    end

    def layers(scope=:all)
      SurfaceLayer.find(scope, :params => { :surface_id => id })
    end

    def create_or_find_layer_by_name(layer_name)
      layer_zip = self.attributes["layers"]
      layer_names = layer_zip.map{|id,name| name }
      idx = layer_names.index(layer_name)
      if idx
        layer_id = layer_zip[idx][0]
        layer = SurfaceLayer.find(layer_id, :params => { :surface_id => id }) if idx
      else
        layer = create_layer(:name => layer_name)
      end
      layer
    end

#    def create_layer(layer_params)
#      layer = SurfaceLayer.new(layer_params)
#      layer.prefix_options[:surface_id] = self.id
#      layer.save
#    end

    def create_layer(params)
      prefix = self.class.prefix
      collection_name = self.class.collection_name + '/' + self.id.to_s + '/layers'
      path = "#{prefix}#{collection_name}#{self.class.format_extension}"
      connection.post(path,ActiveSupport::JSON.encode({surface_layer: params})).tap do |response|
        return response
      end      
    end

    def create_spot(spot_params)
      spot = Spot.new(spot_params)
      spot.prefix_options[:surface_id] = self.id
      spot.save
    end

    def make_tiles
      prefix = self.class.prefix
      collection_name = self.class.collection_name + '/' + self.id.to_s + '/tiles'
      path = "#{prefix}#{collection_name}#{self.class.format_extension}"
      connection.post(path,encode).tap do |response|
        return response
      end
    end

    def make_image_tiles(image_id)
      surface_image = self.images(image_id)
      surface_image.make_tiles
    end

    def make_layer_tiles(layer_id)
      prefix = self.class.prefix
      collection_name = self.class.collection_name + '/' + self.id.to_s + '/layers/' + layer_id.to_s + '/tiles'
      path = "#{prefix}#{collection_name}#{self.class.format_extension}"
      connection.post(path,ActiveSupport::JSON.encode({surface_layer: {id: layer_id}})).tap do |response|
        return response
      end      
    end
  end
end
