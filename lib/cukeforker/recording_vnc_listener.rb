module CukeForker
  class RecordingVncListener < VncListener
    def initialize(pool, opts = {})
      super(pool)
      
      @ext     = opts[:codec] || "mpeg4"
      @options = opts
    end
    
    def on_worker_starting(worker)
      super
      worker.data.recorder = recorder_for(worker)
    end

    def on_worker_finished(worker)
      worker.data.recorder.stop
      worker.data.recorder = nil
      
      super
    end

    private
    
    def recorder_for(worker)
      display = worker.data.vnc.display
      output  = File.join(worker.out, "#{worker.basename}.#{@ext}")
      
      VncTools::Recorder.new display, output, @options
    end

  end # RecordingVncListener
end # CukeForker