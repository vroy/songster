module Songster

  # Holds extra information about the mouth found in Face.
  class Mouth

    attr_reader :left_x, :left_y, :center_x, :center_y, :right_x, :right_y
    attr_reader :left, :center, :right
    attr_reader :x, :y, :width, :height, :top, :middle, :bottom
    attr_reader :opening_size, :chin_height

    # Create a new Mouth object with all the calculated fields of the extra
    # information.
    #
    # @param [Songster::Face] face object that represents the data from the
    #                         face.com API call.
    # @option opts [Integer] :opening_size The size that the mouth will open.
    #                        Defaults to 15.
    def initialize(face, opts={})
      photo_width_percentage = face.photo["width"].to_f/100
      photo_height_percentage = face.photo["height"].to_f/100
      tags = face.tags

      # Calculate the real location of the mouth points in the picture.
      @left_x = (tags["mouth_left"]["x"] * photo_width_percentage).to_i
      @left_y = (tags["mouth_left"]["y"] * photo_height_percentage).to_i
      @left = "#{@left_x},#{@left_y}"

      @center_x = (tags["mouth_center"]["x"] * photo_width_percentage).to_i
      @center_y = (tags["mouth_center"]["y"] * photo_height_percentage).to_i
      @center = "#{@center_x},#{@center_y}"

      @right_x = (tags["mouth_right"]["x"] * photo_width_percentage).to_i
      @right_y = (tags["mouth_right"]["y"] * photo_height_percentage).to_i
      @right = "#{@right_x},#{@right_y}"

      # @todo Currently the left point but could be reviewed to be the highest
      #       vertical point and the most left point.
      @x, @y = left_x, left_y

      # Vertical points of the mouth
      @top, @middle, @bottom = [@left_y, @center_y, @right_y].sort

      # Width and height of the mouth
      @width = @right_x - @left_x
      @height = @bottom - @top

      # Additional information and some optional information.
      @opening_size = opts[:opening_zize] || 15
      @chin_height = (tags["height"] * (photo_height_percentage * 0.3)).to_i
    end

  end # Mouth
end # Songster
