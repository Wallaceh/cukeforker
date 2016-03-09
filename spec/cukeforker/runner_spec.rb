require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe Runner do

    context "creating" do
      it "sets up a new instance" do
        # sigh.

        max       = 4
        format    = :json
        out       = "/tmp"
        listeners = [double(AbstractListener, :update => nil)]
        log       = false
        features  = %w[a b]
        delay     = 1
        fail_fast = false

        mock_queue = double(WorkerQueue)
        mock_workers = Array.new(2) { |n| double("Worker-#{n}") }

        Process.stub(:pid => 1234)

        WorkerQueue.should_receive(:new).with(max, 1, fail_fast).and_return mock_queue
        Worker.should_receive(:new).with("a", :json, "/tmp", []).and_return mock_workers[0]
        Worker.should_receive(:new).with("b", :json, "/tmp", []).and_return mock_workers[1]

        mock_queue.should_receive(:add_observer).once.with listeners.first
        mock_queue.should_receive(:add).with mock_workers[0]
        mock_queue.should_receive(:add).with mock_workers[1]

        Runner.create(features,
          :max        => max,
          :notify     => listeners,
          :format     => format,
          :log        => false,
          :out        => out,
          :delay      => 1,
          :fail_fast  => fail_fast,
        ).should be_kind_of(Runner)
      end

      it "sets up the VNC pool if :vnc => true" do
        mock_pool = double(VncTools::ServerPool, :add_observer => nil)
        VncTools::ServerPool.should_receive(:new).with(2).and_return mock_pool
        VncListener.should_receive(:new).with(mock_pool).and_return double(:update => nil)

        Runner.create([], :max => 2, :vnc => true)
      end

      it "sets up the VNC pool with a custom server class" do
        server_class = Class.new

        mock_pool = double(VncTools::ServerPool, :add_observer => nil)
        VncTools::ServerPool.should_receive(:new).with(2, server_class).and_return mock_pool
        VncListener.should_receive(:new).with(mock_pool).and_return double(:update => nil)

        Runner.create([], :max => 2, :vnc => server_class)
      end

      it "sets up VNC recording if :record => true" do
        mock_pool = double(VncTools::ServerPool, :add_observer => nil)
        VncTools::ServerPool.should_receive(:new).with(2).and_return mock_pool

        mock_vnc_listener = double(:update => nil)
        VncListener.should_receive(:new).with(mock_pool).and_return(mock_vnc_listener)
        RecordingVncListener.should_receive(:new).with(mock_vnc_listener).and_return(double(:update => nil))

        Runner.create([], :max => 2, :vnc => true, :record => true)
      end

      it "sets up VNC recording if :record => Hash" do
        mock_pool = double(VncTools::ServerPool, :add_observer => nil)
        VncTools::ServerPool.should_receive(:new).with(2).and_return mock_pool

        mock_vnc_listener = double(:update => nil)
        VncListener.should_receive(:new).with(mock_pool).and_return(mock_vnc_listener)
        RecordingVncListener.should_receive(:new).with(mock_vnc_listener, :codec => "flv").and_return(double(:update => nil))

        Runner.create([], :max => 2, :vnc => true, :record => {:codec => "flv"})
      end

      it "creates and runs a new runner" do
        r = double(Runner)
        Runner.should_receive(:create).with(%w[a b], {}).and_return(r)
        r.should_receive(:run)

        Runner.run(%w[a b])
      end
    end

    context "running" do
      let(:listener) { double(AbstractListener, :update => nil) }
      let(:queue)    { double(Queue, :has_failures? => false) }
      let(:runner)   { Runner.new(queue) }

      it "processes the queue" do
        runner.add_observer listener

        listener.should_receive(:update).with(:on_run_starting)
        queue.should_receive(:process).with 0.2 # poll interval
        queue.should_receive(:wait_until_finished)
        listener.should_receive(:update).with(:on_run_finished, false)

        runner.run
      end

      it "fires on_run_interrupted and shuts down if the run is interrupted" do
        runner.add_observer listener

        queue.stub(:process).and_raise(Interrupt)
        runner.stub(:stop)
        listener.should_receive(:update).with(:on_run_interrupted)

        runner.run
      end

      it "fires on_run_interrupted and shuts down if an error occurs" do
        runner.add_observer listener

        queue.stub(:process).and_raise(StandardError)
        runner.stub(:stop)
        listener.should_receive(:update).with(:on_run_interrupted)

        lambda { runner.run }.should raise_error(StandardError)
      end
    end

    context 'exit status' do
      let(:queue)    { double(Queue) }
      let(:runner)   { Runner.new(queue) }

      it 'returns true when there are no test failures' do
        queue.stub(:has_failures? => false)
        queue.should_receive(:process).with 0.2 # poll interval
        queue.should_receive(:wait_until_finished)

        expect(runner.run).to be_truthy
      end

      it 'returns false when there are test failures' do
        queue.stub(:has_failures? => true)
        queue.should_receive(:process).with 0.2 # poll interval
        queue.should_receive(:wait_until_finished)

        expect(runner.run).to be_falsey
      end
    end
  end # Runner
end # CukeForker
