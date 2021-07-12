module Tiled
  class Object
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :object_group
    attributes :id, :name, :type, :x, :y, :width, :height, :rotation, :gid, :visible, :template

    def initialize(object_group)
      @object_group = object_group
    end

    # Initialize layer with data from xml hash
    # @param hash [Hash] hash loaded from xml file of map.
    # @return [Tiled::Object] self
    def from_xml_hash(hash)
      attributes.add(hash[:attributes])

      self
    end

    # Get tile by object's gid
    # @return [Tiled::Tile, nil]
    def tile
      map.find_tile(gid.to_i)
    end

    # Method to get array of visible and renderable sprites from layer.
    #
    # By default for sprites used Tiled::Sprite class, but you can override this by passing `sprite_class` argument
    # to Map.new method.
    #
    # @example
    #   args.outputs.sprites << args.state.map.layer['ground'].sprites
    #
    # @return [Tiled::Sprite> sprite.
    def sprite
      return unless visible?
      map_height = map.attributes.height.to_i  * map.attributes.tileheight.to_i
      map.sprite_class.from_tiled(x, map_height - y.to_i, tile)
    end

    def properties
      @properties ||= Properties.new(self)
    end

    def map
      @object_group.map
    end

    # Return `attributes.visible` converted to boolean
    # @return [Boolean]
    def visible?
      visible != '0'
    end

    def exclude_from_serialize
      super
    end
  end
end
