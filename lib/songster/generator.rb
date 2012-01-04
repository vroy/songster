module Songster

  class Generator

    def initialize(image_path)
      @image_path = image_path
    end

    def generate!
      faces = Songster::Image.new(@image_path).detect!

      @dir = Dir.mktmpdir("songster")
      @fname = Pathname.new(@image_path).basename.sub_ext("")

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

      create_side_by_side_example if Songster.debug

      Pathname.new(@dir).rmtree
    end # generate!

    private

    # Resize the original and singing images to 40% of their size
    # and put them side by side.
    def create_side_by_side_example
      # Resize the original image to 40% of the size.
      Commander.run!("convert #{@dir}/original.miff",
                     "-resize 40%",
                     "#{@dir}/original_smaller.miff")

      # Resize the singing image to 40% of the size.
      Commander.run!("convert",
                     Songster.output_folder.join("#{@fname}-singing.gif").to_s,
                     "-resize 50%",
                     "#{@dir}/singing_smaller.miff")

      # Put two closed mouth side by side.
      Commander.run!("convert",
                     "#{@dir}/original_smaller.miff #{@dir}/original_smaller.miff",
                     "+append",
                     "#{@dir}/sidebyside_closed.miff")

      # Put a closed and opened mouth side by side.
      Commander.run!("convert",
                     "#{@dir}/singing_smaller.miff",
                     "+append",
                     "#{@dir}/sidebyside_opened.miff")

      Commander.run!("convert -loop 0 -delay 30",
                     "#{@dir}/sidebyside_closed.miff #{@dir}/sidebyside_opened.miff",
                     Songster.debug_folder.join("#{@fname}-sidebyside.gif").to_s)
    end

    def create_debug_points_canvas
      Commander.run!("convert #{@dir}/original.miff",
                     Songster.debug_folder.join("debug_points.png").to_s)
    end

    def create_debug_points(mouth)
      Commander.run!("mogrify",
                     "-stroke green -fill green",
                     "-draw '",
                     "    circle #{mouth.left} #{mouth.left_x},#{mouth.left_y-2}",
                     "    circle #{mouth.center} #{mouth.center_x},#{mouth.center_y-2}",
                     "    circle #{mouth.right} #{mouth.right_x},#{mouth.right_y-2}",
                     "'",
                     Songster.debug_folder.join("debug_points.png") )
    end

    def convert_original_to_miff
      Commander.run!("convert", @image_path,
                     "-format miff #{@dir}/original.miff")
    end

    # Create a crop of the mouth upper lip with black padding on the bottom
    def create_mouth_top_crop(mouth)
      crop_size = "#{mouth.width}x#{mouth.height+5}"
      crop_location = "+#{mouth.left_x}+#{mouth.top}"

      Commander.run!("convert #{@dir}/original.miff",
                     "-fill black -stroke black",

                     "-draw \"path '",
                     # Start line at the top left point
                     "    M #{mouth.left}",

                     # Draw a curve to the right point.
                     "    C #{mouth.center_x},#{mouth.center_y+5}",
                     "      #{mouth.center_x},#{mouth.center_y+5}",
                     "      #{mouth.right}",

                     # Draw a straight line to a point below the right point.
                     "    L #{mouth.right_x},#{mouth.bottom+5}",

                     # Draw a straight line to a point below the left point.
                     "    L #{mouth.left_x},#{mouth.bottom+5}",

                     # Close the figure so it can be filled.
                     "    Z",
                     "'\"",

                     "-crop #{crop_size}#{crop_location}",

                     "#{@dir}/top.miff")
    end

    # Create a crop of the mouth bottom lip with black padding on the top
    def create_mouth_bottom_crop(mouth)
      crop_size = "#{mouth.width}x#{mouth.chin_height+mouth.opening_size}"
      crop_location = "+#{mouth.left_x}+#{mouth.middle}"

      Commander.run!("convert #{@dir}/original.miff",
                     "-fill black -stroke black",

                     "-draw \"path '",

                     # Start line at the top left point
                     "    M #{mouth.left}",

                     # Draw a curve to the right point
                     "    C #{mouth.center_x},#{mouth.center_y+5}",
                     "      #{mouth.center_x},#{mouth.center_y+5}",

                     # Finish line at the right point.
                     "      #{mouth.right}'",
                     "\"",

                     # Add black padding to adjust how big the mouth opens.
                     "-gravity northwest -background black",
                     "-splice 0x#{mouth.opening_size}+0+#{mouth.middle}",

                     # Crop to get the results.
                     "-crop #{crop_size}#{crop_location}",

                     "#{@dir}/bottom.miff")
    end

    # Merge the top and bottom part of the mouth to create the opened mouth.
    def merge_top_and_bottom_of_mouth
      Commander.run!("convert #{@dir}/top.miff #{@dir}/bottom.miff",
                     "-append #{@dir}/opened_mouth.miff")
    end

    def create_opened_mouths_canvas
      Commander.run!("convert #{@dir}/original.miff #{@dir}/opened_mouths.miff")
    end

    # Put the opened mouth over the original image.
    def merge_opened_mouth_on_canvas(mouth)
      Commander.run!("composite",
                     "#{@dir}/opened_mouth.miff #{@dir}/opened_mouths.miff",
                     "-gravity northwest -geometry +#{mouth.x}+#{mouth.y}",
                     "#{@dir}/opened_mouths.miff")
    end

    # Build a gif of the original image and the image with opened mouths
    def animate_into_gif
      animate = Commander.new("convert -loop 0 -delay 30")
      animate << "#{@dir}/original.miff #{@dir}/opened_mouths.miff"
      animate << Songster.output_folder.join("#{@fname}-singing.gif").to_s
      animate.run!
    end

  end # Generator
end # Songster
