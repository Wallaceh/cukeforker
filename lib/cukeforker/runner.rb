module CukeForker

  #
  # Runner.run(features, opts)
  #
  # where 'features' is an Array of file:line
  # and 'opts' is a Hash of options:
  #
  #   :max        => max          number of workers (default: 2)
  #   :vnc        => true/false   children are launched with DISPLAY set from a VNC server pool,
  #                               where the size of the pool is equal to :max
  #   :notify     => object       (or array of objects) implementing the AbstractListener API
  #   :out        => path         directory to dump output to (default: current working dir)
  #   :log        => true/false   wether or not to log to stdout (default: true)
  #

  class Runner
    include Observable

    DEFAULT_OPTIONS = {
      :max    => 2,
      :vnc    => false,
      :notify => [],
      :out    => Dir.pwd,
      :log    => true
    }

    def self.run(*args)
      new(*args).run
    end

    def initialize(features, opts = {})
      opts = DEFAULT_OPTIONS.dup.merge(opts)

      max        = opts[:max]
      listeners = Array(opts[:notify])

      if opts[:log]
        listeners << LoggingListener.new
      end

      @queue = WorkerQueue.new max
      @vncs = DisplayPool.new max

      listeners.each { |listener|
        @queue.add_observer listener
        add_observer listener
      }
    end

    def run
      start
      loop
    ensure # also catches Interrupt
      stop
    end

    private

    def start
      @start_time = Time.now

      changed
      notify_observers :on_run_starting
    end

    def loop
      # TODO: move to WorkerQueue
      while @queue.backed_up?
        @queue.fill
        @queue.poll(0.2) while @queue.full?
      end

      # aight, no more features pending!
    end

    def stop
      # wait for the last batch to finish
      @queue.poll(0.2) until @queue.empty?

      failed = @queue.finished.any? { |w| w.failed? }

      changed
      notify_observers :on_run_finished, failed
    end

  end # Runner
end # CukeForker
