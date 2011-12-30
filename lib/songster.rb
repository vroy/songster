# Stdlib libraries:
require "tmpdir"
require "pathname"

# Gem dependencies:
require "face"
require "colorize"

# Songster:
require_relative "songster/commander"
require_relative "songster/face"
require_relative "songster/mouth"
require_relative "songster/generator"

module Songster

  class << self
    attr_accessor :api_key, :api_secret, :debug
    @api_key = nil
    @api_secret = nil
    @debug = false

    # Generates a gif of singing people for all the faces found in the image
    # provided. This is a wrapper around the ImageMagick command line tools
    # and uses the command line tools directly.
    def generate!(image_path)
      Generator.new(image_path).generate!
    end
  end

end # Songster
