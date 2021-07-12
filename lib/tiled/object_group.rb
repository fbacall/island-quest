module Tiled
  class ObjectGroup
    include Tiled::Serializable
    include Tiled::WithAttributes

    attr_reader :map, :objects
    attributes :id, :name, :color, :x, :y, :width, :height, :opacity, :visible, :tintcolor, :offsetx, :offsety, :draworder

    def initialize(map)
      @map = map
    end

    # Initialize layer with data from xml hash
    # @param hash [Hash] hash loaded from xml file of map.
    # @return [Tiled::Layer] self
    def from_xml_hash(hash)
      attributes.add(hash[:attributes])

      hash[:children].each do |child|
        case child[:name]
        when 'properties'
          properties.from_xml_hash(child[:children])
        when 'object'
          @objects ||= []
          @objects << Tiled::Object.new(self).from_xml_hash(child)
        end
      end

      self
    end

    # Method to get array of visible and renderable sprites from object group.
    #
    # By default for sprites used Tiled::Sprite class, but you can override this by passing `sprite_class` argument
    # to Map.new method.
    #
    # @example
    #   args.outputs.sprites << args.state.map.layer['ground'].sprites
    #
    # @return [Array<Tiled::Sprite>] array of sprite objects.
    # @return [Map#sprite_class] array of objects of custom class.
    def sprites
      @sprites = @objects.map(&:sprite)
    end

    def properties
      @properties ||= Properties.new(self)
    end

    # Return `attributes.visible` converted to boolean
    # @return [Boolean]
    def visible?
      visible != '0'
    end

    def exclude_from_serialize
      super + %w[objects sprites]
    end
  end
end
