module Songster

  # Abstraction on top of ::Face the gem to the face.com API.
  class Image
    # Setup the information required to make the API call to face.com.
    def initialize(image_path)
      @image_path = image_path
      @client = ::Face.get_client(api_key: Songster.api_key,
                                  api_secret: Songster.api_secret)
    end

    # Make the API call to the face.com and return a list of faces found.
    #
    # @return [Array -> Face]
    def detect!
      faces = [ ]
      results = @client.faces_detect(file: File.new(@image_path, "rb"))
      photo = results["photos"][0]

      photo["tags"].each do |face_tags|
        faces << Face.new(face_tags, photo)
      end

      faces
    end

  end # Image
end # Songster
