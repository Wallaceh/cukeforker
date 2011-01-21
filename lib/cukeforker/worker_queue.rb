module CukeForker
  class WorkerQueue
    include Observable

    attr_reader :finished

    def initialize(max)
      @max = max

      @pending = []
      @running = []
      @finished = []
    end

    def backed_up?
      @pending.any?
    end

    def add(worker)
      @pending << worker
    end

    def process(poll_interval = nil)
      @start_time = Time.now

      while backed_up?
        fill
        fire :on_eta, eta
        poll poll_interval while full?
      end

      # yay, no more pending workers
    end

    def wait_until_finished(poll_interval = nil)
      poll poll_interval until empty?
    end

    def fill
      while backed_up? and not full?
        worker = @pending.shift
        start worker
      end
    end

    def poll(seconds = nil)
      finished = @running.select { |w| w.finished? }

      if finished.empty?
        sleep seconds if seconds
      else
        finished.each { |w| finish w }
      end
    end

    def size
      @running.size
    end

    def full?
      size == @max
    end

    def empty?
      @running.empty?
    end

    def has_failures?
      @finished.any? { |w| w.failed? }
    end

    private

    def start(worker)
      fire :on_worker_starting, worker

      worker.start
      @running << worker
    end

    def finish(worker)
      @running.delete worker
      @finished << worker

      fire :on_worker_finished, worker
    end

    def eta
      return Time.now if @finished.empty?

      pending = @pending.size
      finished = @finished.size

      seconds_per_child = (Time.now - @start_time) / finished
      eta = Time.now + (seconds_per_child * pending)

      eta
    end

    def fire(*args)
      changed
      notify_observers(*args)
    end

  end # WorkerQueue
end # CukeForker
