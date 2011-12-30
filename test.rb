$LOAD_PATH.unshift File.dirname(File.expand_path(__FILE__))

require "lib/songster"

face_config = JSON.parse( IO.read("face.json") )

Songster.api_key = face_config["api_key"]
Songster.api_secret = face_config["api_secret"]
Songster.debug = true

Songster.generate!("images/me.jpg")
