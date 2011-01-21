module CukeForker
  class VncServerPool
    include Observable

    def initialize(capacity, klass = VncServer)
      @capacity = capacity
      @servers  = Array.new(capacity) { klass.new }
      @running  = []
    end

    def stop
      running.each do |s|
        fire :on_display_stopping, s
        s.stop
      end
    end

    def size
      @servers.size
    end

    def get
      raise OutOfDisplaysError if @servers.empty?

      server = next_server
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

    def running
      @running
    end

    def next_server
      server = @servers.shift

      if server.display.nil?
        fire :on_display_starting, server
        server.start
        @running << server
      end

      server
    end

    class TooManyDisplaysError < StandardError
    end

    class OutOfDisplaysError < StandardError
    end

  end # DisplayPool
end # CukeForker
