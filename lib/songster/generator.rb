module Songster

  class Generator

    def initialize(image_path)
      @image_path = image_path
    end

    def generate!
      faces = Songster::Image.new(@image_path).detect!

      @dir = Dir.mktmpdir("songster")

      puts "Putting temporary files in #{@dir}".green if Songster.debug

      convert_original_to_miff
      create_opened_mouths_canvas

      create_debug_points_canvas if Songster.debug

      faces.each do |face|
        create_mouth_top_crop(face.mouth)
        create_mouth_bottom_crop(face.mouth)
        merge_top_and_bottom_of_mouth

        merge_opened_mouth_on_canvas(face.mouth)

        create_debug_points(face.mouth) if Songster.debug
      end

      animate_into_gif

      Pathname.new(@dir).rmtree
    end # generate!

    private

    def create_debug_points_canvas
      Commander.new("convert #{@dir}/original.miff",
                    Songster.debug_folder.join("debug_points.png").to_s).run!
    end

    def create_debug_points(mouth)
      Commander.new("mogrify",
                    "-stroke green -fill green",
                    "-draw '",
                    "    circle #{mouth.left_x},#{mouth.left_y} #{mouth.left_x},#{mouth.left_y-2}",
                    "    circle #{mouth.center_x},#{mouth.center_y} #{mouth.center_x},#{mouth.center_y-2}",
                    "    circle #{mouth.right_x},#{mouth.right_y} #{mouth.right_x},#{mouth.right_y-2}",
                    "'",
                    Songster.debug_folder.join("debug_points.png") ).run!
    end

    def convert_original_to_miff
      Commander.new("convert", @image_path,
                    "-format miff #{@dir}/original.miff").run!
    end

    # Create a crop of the mouth upper lip with black padding on the bottom
    def create_mouth_top_crop(mouth)
      crop_size = "#{mouth.width}x#{mouth.height+5}"
      crop_location = "+#{mouth.left_x}+#{mouth.top}"

      Commander.new("convert #{@dir}/original.miff",
                    "-fill black -stroke black",

                    "-draw \"path '",
                    # Start line at the top left point
                    "    M #{mouth.left_x},#{mouth.left_y}",

                    # Draw a curve to the right point.
                    "    C #{mouth.center_x},#{mouth.center_y+5}",
                    "      #{mouth.center_x},#{mouth.center_y+5}",
                    "      #{mouth.right_x},#{mouth.right_y}",

                    # Draw a straight line to a point below the right point.
                    "    L #{mouth.right_x},#{mouth.bottom+5}",

                    # Draw a straight line to a point below the left point.
                    "    L #{mouth.left_x},#{mouth.bottom+5}",

                    # Close the figure so it can be filled.
                    "    Z",
                    "'\"",

                    "-crop #{crop_size}#{crop_location}",

                    "#{@dir}/top.miff").run!
    end

    # Create a crop of the mouth bottom lip with black padding on the top
    def create_mouth_bottom_crop(mouth)
      crop_size = "#{mouth.width}x#{mouth.chin_height+mouth.opening_size}"
      crop_location = "+#{mouth.left_x}+#{mouth.middle}"

      Commander.new("convert #{@dir}/original.miff",
                    "-fill black -stroke black",

                    "-draw \"path '",

                    # Start line at the top left point
                    "    M #{mouth.left_x},#{mouth.left_y}",

                    # Draw a curve to the right point
                    "    C #{mouth.center_x},#{mouth.center_y+5}",
                    "      #{mouth.center_x},#{mouth.center_y+5}",

                    # Finish line at the right point.
                    "      #{mouth.right_x},#{mouth.right_y}'",
                    "\"",

                    # Add black padding to adjust how big the mouth opens.
                    "-gravity northwest -background black",
                    "-splice 0x#{mouth.opening_size}+0+#{mouth.middle}",

                    # Crop to get the results.
                    "-crop #{crop_size}#{crop_location}",

                    "#{@dir}/bottom.miff").run!
    end

    # Merge the top and bottom part of the mouth to create the opened mouth.
    def merge_top_and_bottom_of_mouth
      Commander.new("convert #{@dir}/top.miff #{@dir}/bottom.miff",
                    "-append #{@dir}/opened_mouth.miff").run!
    end

    def create_opened_mouths_canvas
      Commander.new("convert #{@dir}/original.miff #{@dir}/opened_mouths.miff").run!
    end

    # Put the opened mouth over the original image.
    def merge_opened_mouth_on_canvas(mouth)
      Commander.new("composite #{@dir}/opened_mouth.miff #{@dir}/opened_mouths.miff",
                    "-gravity northwest -geometry +#{mouth.x}+#{mouth.y}",
                    "#{@dir}/opened_mouths.miff").run!
    end

    # Build a gif of the original image and the image with opened mouths
    def animate_into_gif
      fname = Pathname.new(@image_path).basename.sub_ext("")

      animate = Commander.new("convert -loop 0 -delay 30")
      animate << "#{@dir}/original.miff #{@dir}/opened_mouths.miff"
      animate << Songster.output_folder.join("#{fname}-singing.gif").to_s
      animate.run!
    end

  end # Generator
end # Songster
