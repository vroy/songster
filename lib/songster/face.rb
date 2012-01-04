module Songster

  # Provide access to the details of a Face found in Songster::Image
  class Face

    attr_reader :tags, :photo, :mouth

    # Setup the information required to make the API call to face.com.
    def initialize(tags, photo)
      @tags = tags
      @photo = photo
      @mouth = Mouth.new(self)
    end

  end # Face

end # Songster
