module CukeForker
  class VncListener < AbstractListener
    def initialize(pool)
      @pool = pool
    end

    def on_worker_starting(worker)
      worker.vnc = @pool.get
    end

    def on_worker_finished(worker)
      @pool.release worker.vnc
      worker.vnc = nil
    end

    def on_run_finished(failed)
      @pool.stop
    end

  end # VncListener
end # CukeForker