require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe LoggingListener do
    let(:stdout)   { StringIO.new }
    let(:listener) { LoggingListener.new stdout }

    it "logs all events" do
      Time.stub(:now => Time.now)

      mock_worker  = double(Worker,     :id => "1", :feature => "foo/bar", :failed? => false)
      mock_worker2 = double(Worker,     :id => "15", :feature => "foo/baz", :failed? => true)

      mock_display = double(VncTools::Server)
      mock_display.stub(:display).and_return(nil, ":5", ":15")

      listener.on_run_starting
      listener.on_display_starting mock_display
      listener.on_display_fetched mock_display
      listener.on_worker_starting mock_worker
      listener.on_worker_forked mock_worker
      listener.on_worker_starting mock_worker2
      listener.on_worker_forked mock_worker2
      listener.on_eta Time.now, 10, 255
      listener.on_worker_finished mock_worker
      listener.on_worker_finished mock_worker2
      listener.on_display_released mock_display
      listener.on_run_interrupted
      listener.on_run_finished false
      listener.on_display_stopping mock_display

      timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S##{Process.pid}")

      stdout.string.should == <<-OUTPUT
I, [#{timestamp}]  INFO -- : [    run           ] starting
I, [#{timestamp}]  INFO -- : [    display       ] starting
I, [#{timestamp}]  INFO -- : [    display :5    ] fetched
I, [#{timestamp}]  INFO -- : [    worker  1     ] starting: foo/bar
I, [#{timestamp}]  INFO -- : [    worker  1     ] forked  : foo/bar
I, [#{timestamp}]  INFO -- : [    worker  15    ] starting: foo/baz
I, [#{timestamp}]  INFO -- : [    worker  15    ] forked  : foo/baz
I, [#{timestamp}]  INFO -- : [    eta     10/255] #{Time.now.strftime "%Y-%m-%d %H:%M:%S"}
I, [#{timestamp}]  INFO -- : [    running       ] ["1", "15"]
I, [#{timestamp}]  INFO -- : [    worker  1     ] passed  : foo/bar
I, [#{timestamp}]  INFO -- : [    worker  15    ] failed  : foo/baz
I, [#{timestamp}]  INFO -- : [    display :15   ] released
I, [#{timestamp}]  INFO -- : [    run           ] interrupted - please wait
I, [#{timestamp}]  INFO -- : [    run           ] finished, passed
I, [#{timestamp}]  INFO -- : [    display :15   ] stopping
      OUTPUT
    end
  end # Worker
end # CukeForker
