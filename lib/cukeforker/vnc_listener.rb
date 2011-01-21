module CukeForker
  class VncListener
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
    
  end # VncListener
end # CukeForker