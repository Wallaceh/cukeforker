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

    private

    def finished_workers

    end

    def start(worker)
      changed
      notify_observers :on_worker_starting, worker

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
