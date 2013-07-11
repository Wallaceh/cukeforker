require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe RecordingVncListener do
    let(:server)       { double(VncTools::Server, :display => ":2")}
    let(:vnc_listener) { double(VncListener).as_null_object  }
    let(:worker)       { double(Worker, :data => OpenStruct.new(:vnc => server), :out => ".", :basename => "foo", :failed? => true) }
    let(:recorder)     { double(VncTools::Recorder, :start => nil, :stop => nil, :output => "foo.mp4")   }
    let(:listener)     { RecordingVncListener.new vnc_listener }

    it "forwards messages to the wrapped listener do" do
      VncTools::Recorder.should_receive(:new).and_return(recorder)

      # TODO: better way to do this

      vnc_listener.should_receive :on_run_starting
      vnc_listener.should_receive :on_worker_starting
      vnc_listener.should_receive :on_worker_finished
      vnc_listener.should_receive :on_worker_forked
      vnc_listener.should_receive :on_run_interrupted
      vnc_listener.should_receive :on_run_finished
      vnc_listener.should_receive :on_display_fetched
      vnc_listener.should_receive :on_display_released
      vnc_listener.should_receive :on_display_starting
      vnc_listener.should_receive :on_display_stopping
      vnc_listener.should_receive :on_eta

      listener.on_run_starting
      listener.on_worker_starting worker
      listener.on_worker_finished worker
      listener.on_worker_forked worker
      listener.on_run_interrupted
      listener.on_run_finished
      listener.on_display_fetched
      listener.on_display_released
      listener.on_display_starting
      listener.on_display_stopping
      listener.on_eta
    end

    it "starts recording when the worker is started" do
      VncTools::Recorder.should_receive(:new).with(":2", "./foo.mp4", {}).and_return(recorder)
      recorder.should_receive(:start)

      listener.on_worker_starting worker
    end

    it "stops recording when the worker is finished" do
      worker.data.recorder = recorder
      recorder.should_receive(:stop)

      listener.on_worker_finished worker

      worker.data.recorder.should be_nil
    end

    it "deletes the output file if the worker succeeded" do
      worker.data.recorder = recorder
      recorder.stub(:stop)

      worker.should_receive(:failed?).and_return(false)
      recorder.should_receive(:output).and_return("./foo.mp4")
      FileUtils.should_receive(:rm_rf).with("./foo.mp4")

      listener.on_worker_finished worker
    end

    it "stops all recorders when the run is interrupted" do
      VncTools::Recorder.should_receive(:new).with(":2", "./foo.mp4", {}).and_return(recorder)
      recorder.should_receive(:start)

      listener.on_worker_starting worker
      recorder.should_receive(:stop)

      listener.on_run_interrupted
    end

    it "passes along options to each recorder" do
      listener = RecordingVncListener.new vnc_listener, :codec => "flv"
      VncTools::Recorder.should_receive(:new).with(":2", "./foo.flv", :codec => "flv").and_return(recorder)

      listener.on_worker_starting worker
    end

  end # RecordingVncListener
end # CukeForker
