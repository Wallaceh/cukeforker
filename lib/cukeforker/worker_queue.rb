module CukeForker
  class WorkerQueue
    include Observable

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
        eta
        poll poll_interval while full?
      end

      # yay, no more pending workers
    end

    def wait_until_finished(poll_interval = nil)
      until empty?
        poll poll_interval
        eta
      end
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

    def eta
      pending  = @pending.size
      finished = @finished.size
      running  = @running.size

      remaining = pending + running

      if finished == 0
        result = [Time.now, remaining, finished]
        fire :on_eta, *result
      else
        seconds_per_child = (Time.now - start_time) / finished.to_f
        eta = Time.now + (seconds_per_child * remaining)

        result = [eta, remaining, finished]

        fire :on_eta, *result
      end

      result
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

    def fire(*args)
      changed
      notify_observers(*args)
    end

    def start_time
      @start_time or raise NotStartedError
    end

    class NotStartedError < StandardError; end

  end # WorkerQueue
end # CukeForker
