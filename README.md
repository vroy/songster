# Songster

Turn every face found in your images into singing faces. -- ALPHA --

# Usage

This is meant to be a ruby gem but is currently not bundled up due to the
current status of the code (not totally stable yet).

To use it at the moment, you can have a look at the test.rb file. To run it on
the test images I provided, you can run `ruby test.rb images/me.jpg` or
`ruby test.rb images/me-double.jpg`

# Examples

### Single face example
![Two Face Singing Example](https://github.com/exploid/songster/raw/master/images/me-sidebyside.gif)

### Two face example
![Two Face Singing Example](https://github.com/exploid/songster/raw/master/images/me-double-sidebyside.gif)

# Dependencies

### face.com

You will need your own face.com API key and secret. See the
[developer page](http://developers.face.com/)

### Ruby

This has only been tested with ruby 1.9.2 so far.

### Gems

I provided a Gemfile/Gemfile.lock so you can run bundle install from the root
folder and it should install the required gems.

### ImageMagick

You need the ImageMagick command line tools added to your PATH. See the
ImageMagick website for installation instructions for your platform:
http://imagemagick.org/

# TODO

As previously stated, this is in alpha and there are still a lot of improvements
to be made and you should not expect that this works out of the box with all of
your pictures.
