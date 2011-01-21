require "socket"

module CukeForker
  class VncServer

    class Error < StandardError
    end

    class << self
      def displays
        Dir[File.expand_path("~/.vnc/*.pid")].map { |e| e[/(\d+)\.pid/, 1] }.compact
      end

      def all
        displays.map { |display| new ":#{display}" }
      end
    end

    attr_reader :display

    def initialize(display = nil)
      @display = display
    end

    def start
      if @display
        server @display
      else
        output = server
        @display = output[/desktop is #{host}(\S+)/, 1]
      end
    end

    def stop
      server "-kill", @display.to_s
    end

    private

    def server(*args)
      out = `tightvncserver #{args.join ' '} 2>&1`

      unless $?.success?
        raise Error, "could not run tightvncserver: #{out.inspect}"
      end

      out
    end

    def host
      @host ||= Socket.gethostname
    end
  end # VncServer
end # CukeForker



