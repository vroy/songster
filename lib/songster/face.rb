module Songster

  # Abstraction on top of ::Face the gem to the face.com API. Mostly related to
  # the fact that we provide direct access to the first photo of photos and tags
  # of the first face by default.
  class Face

    attr_reader :photo, :tags

    # Setup the information required to make the API call to face.com.
    def initialize(image_path)
      @image_path = image_path
      @client = ::Face.get_client(api_key: Songster.api_key,
                                  api_secret: Songster.api_secret)
    end

    # Make the API call to the face.com and set the @photo and @tags variables.
    #
    # @return [Face] self
    def detect!
      faces = @client.faces_detect(file: File.new(@image_path, "rb"))
      @photo = faces["photos"][0]
      @tags = @photo["tags"][0]
      self
    end

    # Create a Mouth for self.
    #
    # @return [Mouth] mouth information that is found in self.
    def mouth
      Mouth.new(self)
    end
  end # Face

end # Songster
