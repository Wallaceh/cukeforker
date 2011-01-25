module CukeForker
  class VncListener < AbstractListener
    def initialize(pool)
      @pool = pool
    end

    def on_worker_starting(worker)
      worker.data.vnc = @pool.get
    end

    def on_worker_finished(worker)
      @pool.release worker.data.vnc
      worker.data.vnc = nil
    end

    def on_worker_forked(worker)
      ENV['DISPLAY'] = worker.data.vnc.display
    end

    def on_run_finished(failed)
      @pool.stop
    end

  end # VncListener
end # CukeForker