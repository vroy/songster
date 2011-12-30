module Songster

  # Provide access to the details of a Face found in Songster::Image
  class Face

    attr_reader :tags, :photo

    # Setup the information required to make the API call to face.com.
    def initialize(tags, photo)
      @tags = tags
      @photo = photo
    end

    # Create a Mouth for self.
    #
    # @return [Array -> Mouth] information about the mouth that was found.
    def mouth
      Mouth.new(self)
    end
  end # Face

end # Songster
