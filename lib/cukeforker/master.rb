module CukeForker
  class Master
    DEFAULT_MAX_SLAVES = 2
    DEFAULT_FORMAT     = :json

    #
    # @param features List of features (file:line) to run
    #
    # Options:
    #   :vnc      => true, false # launch and assign a VNC display to each worker
    #   :listener => object that implements the Listener API
    #   :format   => a format passed to `cucumber --format` (default: json)
    #   :args     => extra arguments passed to cucumber
    #
    # Listener API:
    #
    #    on_feature_started(worker)  # called right before forking a worker
    #    on_feature_finished(worker) # called when the worker has finished
    #


    def initialize(features, opts = {})
      assert_unix

      @vnc           = opts.fetch :vnc, false
      @listener      = opts[:listener]
      @shutting_down = false

      format = opts.fetch :format, DEFAULT_FORMAT
      args   = opts.fetch :args,   []
      out    = opts.fetch :out,    Dir.pwd

      @manager = Manager.new opts.fetch(:max, DEFAULT_MAX_SLAVES)
      features.map { |f|
        @manager.queue Worker.new(f, format, args, out)
      }

      trap('INT') { shutdown }
      trap('TERM') { shutdown }
    end

    def run
      manager.run
      quit
    end

    private

    def shutdown
      CukeForker.shutting_down!
      log.warn "shutting down!"

      @manager.wait_until_finished
      log.info "all workers exited"

      quit
    end

    def log
      CukeForker.log
    end

    def quit
      manager.log_finished
      exit manager.failed? ? 1 : 0
    end

    private

    def manager
      @manager
    end

  end # Master
end # CukeForker
