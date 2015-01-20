module Minimart
  class Output

    attr_reader :io

    def initialize(io)
      @io = io
    end

    def puts(*args)
      io.puts(args)
    end

    def puts_red(str)
      puts "\e[31m#{str}\e[0m"
    end

    def puts_green(str)
      puts "\e[32m#{str}\e[0m"
    end

  end
end
