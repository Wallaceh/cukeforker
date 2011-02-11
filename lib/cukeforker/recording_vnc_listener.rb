module CukeForker
  class RecordingVncListener < AbstractListener
    extend Forwardable

    def_delegators :@listener, :on_run_starting, :on_worker_finished, :on_worker_forked,
                              :on_run_interrupted, :on_run_finished, :on_display_fetched,
                              :on_display_released, :on_display_starting, :on_display_stopping,
                              :on_eta


    def initialize(listener, opts = {})
      @listener = listener
      @ext      = opts[:codec] || "mp4"
      @options  = opts

      @recorders = []
    end

    def on_worker_starting(worker)
      @listener.on_worker_starting(worker)

      @recorders << worker.data.recorder = recorder_for(worker)
      worker.data.recorder.start
    end

    def on_worker_finished(worker)
      recorder = worker.data.recorder
      recorder.stop

      unless worker.failed?
        FileUtils.rm_rf recorder.output
      end

      @recorders.delete(recorder)
      worker.data.recorder = nil

      @listener.on_worker_finished(worker)
    end

    def on_run_interrupted
      @listener.on_run_interrupted

      @recorders.each do |recorder|
        recorder.stop rescue nil
      end
    end

    private

    def recorder_for(worker)
      display = worker.data.vnc.display
      output  = File.join(worker.out, "#{worker.basename}.#{@ext}")

      VncTools::Recorder.new display, output, @options
    end

  end # RecordingVncListener
end # CukeForker