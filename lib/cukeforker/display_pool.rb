module CukeForker

  class DisplayPool
    def initialize(capacity, klass = VncServer)
      @capacity = capacity
      @servers  = Array.new(capacity) { klass.new }
    end

    def size
      @servers.size
    end

    def get
      @servers.shift or raise OutOfDisplaysError
    end

    def release(server)
      raise TooManyDisplaysError if size == @capacity
      @servers.unshift server
    end

    class TooManyDisplaysError < StandardError
    end

    class OutOfDisplaysError < StandardError
    end

  end # DisplayPool
end # CukeForker
