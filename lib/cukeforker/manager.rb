module CukeForker
  class Manager
    def initialize(max_concurrency, listener = nil)
      @pending, @finished = [], []
      @running = Queue.new max_concurrency
      @listener = listener || AbstractListener.new
    end

    def finished?
      @pending.empty? && @running.empty?
    end

    def queue(worker)
      @pending << worker
    end

    def run
      @start_time = Time.now
      churn until CukeForker.shutting_down? || @pending.empty?
      wait_until_finished
    end

    def churn
      until @running.full? || @pending.empty? || CukeForker.shutting_down?
        launch_next
      end

      unless CukeForker.shutting_down?
        log_running
        log_eta

        wait
      end
    end

    def finished_workers
      @running.items.select { |worker| worker.finished? }
    end

    def failed?
      @finished.any? { |worker| worker.failed? }
    end

    def wait_until_finished
      return if finished?

      (
        remaining = @running.size
        log.debug "waiting for #{remaining} worker#{'s' if remaining > 1}"
        log_running

        wait
        sleep 0.5
      ) until @running.empty?
    end

    private

    def finish(worker)
      @running.delete worker
      @finished << worker

      listener.on_worker_finished(worker)
    end

    def launch_next
      worker = @pending.shift

      listener.on_worker_started(worker)
      log.debug "starting: #{worker.text}"
      worker.start
      @running << worker
    end

    def wait
      while (done = finished_workers).empty?
        sleep 0.2
      end

      log.info "finished: #{done.inspect}"
      done.each { |worker| finish worker }
    end

    def log_running
      @running.each do |worker|
        log.info "#{worker.pid} [#{worker.feature}]"
      end
    end

    def log_finished
      @finished.each { |w| log.info w.text }
    end

    def log_eta
      log.info "running: #{@running.size}, finished: #{@finished.size}, pending: #{@pending.size}, eta: #{eta}"
    end

    def eta
      return 'infinity' if @finished.empty?

      pending = @pending.size
      finished = @finished.size

      seconds_per_worker = (Time.now - @start_time) / finished
      eta = Time.now + (seconds_per_worker * pending)

      "#{eta.strftime TIME_FORMAT}"
    end

    def log
      CukeForker.log
    end

    def listener
      @listener
    end

  end # Manager
end # CukeForker
