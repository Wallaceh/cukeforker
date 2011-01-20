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

    def fill
      while backed_up? and not full?
        worker = @pending.shift
        start worker
      end
    end

    def poll
      finished_workers.each do |w|
        finish w
      end
    end

    def size
      @running.size
    end

    def full?
      size == @max
    end

    private

    def finished_workers
      @running.select { |w| w.finished? }
    end

    def start(worker)
      changed
      notify_observers :on_worker_started, worker

      worker.start
      @running << worker
    end

    def finish(worker)
      @running.delete worker
      @finished << worker

      changed
      notify_observers :on_worker_finished, worker
    end

  end # WorkerQueue
end # CukeForker
