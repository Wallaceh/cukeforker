module CukeForker
  class VncServerPool
    include Observable

    def initialize(capacity, klass = VncServer)
      @capacity = capacity
      @servers  = Array.new(capacity) { klass.new }
    end

    # or do this on demand?
    def launch
      # TODO: logging
      @servers.each { |s| s.start }
    end

    def size
      @servers.size
    end

    def get
      raise OutOfDisplaysError if @servers.empty?

      server = @servers.shift
      fire :on_display_fetched, server

      server
    end

    def release(server)
      raise TooManyDisplaysError if size == @capacity
      fire :on_display_released, server

      @servers.unshift server
    end

    private

    def fire(*args)
      changed
      notify_observers(*args)
    end

    class TooManyDisplaysError < StandardError
    end

    class OutOfDisplaysError < StandardError
    end

  end # DisplayPool
end # CukeForker
