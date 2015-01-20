module Minimart
  # Wrapper for IO to provide colored output.
  class Output

    attr_reader :io

    def initialize(io)
      @io = io
    end

    def puts(*args)
      io.puts(args)
    end

    def puts_red(str)
      puts_color(31, str)
    end

    def puts_green(str)
      puts_color(32, str)
    end

    def puts_yellow(str)
      puts_color(33, str)
    end

    private

    def puts_color(color_code, str)
      self.puts "\e[#{color_code}m#{str}\e[0m"
    end

  end
end
