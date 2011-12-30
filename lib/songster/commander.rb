module Songster

  # Super simple helper to build/run system call strings.
  class Commander < Array

    # Start a command chain.
    # @param [Array] *args that should be pushed to the system call string.
    def initialize(*args)
      args.each do |arg|
        self.push arg
      end
    end

    # @return [String] the built system call string
    def to_s
      return self.join(" ")
    end

    def self.run!(*args)
      self.new(*args).run!
    end

    # Run the system call string
    def run!
      cmd = self.to_s
      puts ("="*100).blue if Songster.debug
      puts "`#{cmd}`".green if Songster.debug
      output = `#{self.to_s}`
      puts output.red if Songster.debug
      return output
    end

  end # Commander

end # Songster
