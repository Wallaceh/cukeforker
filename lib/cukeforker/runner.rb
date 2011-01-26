module CukeForker

  #
  # Runner.run(features, opts)
  #
  # where 'features' is an Array of file:line
  # and 'opts' is a Hash of options:
  #
  #   :max        => Fixnum       number of workers (default: 2)
  #   :vnc        => true/false   children are launched with DISPLAY set from a VNC server pool,
  #                               where the size of the pool is equal to :max
  #   :notify     => object       (or array of objects) implementing the AbstractListener API
  #   :out        => path         directory to dump output to (default: current working dir)
  #   :log        => true/false   wether or not to log to stdout (default: true)
  #   :format     => Symbol       format passed to `cucumber --format` (default: html)
  #   :extra_args => Array        extra arguments passed to cucumber
  #

  class Runner
    include Observable

    DEFAULT_OPTIONS = {
      :max    => 2,
      :vnc    => false,
      :notify => [],
      :out    => Dir.pwd,
      :log    => true,
      :format => :html
    }

    def self.run(features, opts = {})
      create(features, opts).run
    end

    def self.create(features, opts = {})
      opts = DEFAULT_OPTIONS.dup.merge(opts)

      max        = opts[:max]
      format     = opts[:format]
      out        = File.join opts[:out], Process.pid.to_s
      listeners  = Array(opts[:notify])
      extra_args = Array(opts[:extra_args])

      if opts[:log]
        listeners << LoggingListener.new
      end

      if opts[:vnc]
        vnc_pool = VncServerPool.new(max)
        listeners << VncListener.new(vnc_pool)
      end

      queue = WorkerQueue.new max
      features.each do |feature|
        queue.add Worker.new(feature, format, out, extra_args)
      end

      runner = Runner.new queue

      listeners.each { |listener|
        queue.add_observer listener
        runner.add_observer listener
        vnc_pool.add_observer listener if opts[:vnc]
      }

      runner
    end

    def initialize(queue)
      @queue = queue
    end

    def run
      start
      process
      stop
    rescue Interrupt
      fire :on_run_interrupted
      stop
    rescue StandardError
      fire :on_run_interrupted
      stop
      raise
    end

    private

    def start
      fire :on_run_starting
    end

    def process
      @queue.process 0.2
    end

    def stop
      @queue.wait_until_finished 0.5
    ensure # catch potential second Interrupt
      fire :on_run_finished, @queue.has_failures?
    end

    def fire(*args)
      changed
      notify_observers(*args)
    end

  end # Runner
end # CukeForker
