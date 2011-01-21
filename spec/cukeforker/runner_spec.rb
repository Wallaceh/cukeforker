require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe Runner do

    context "creating" do
      it "sets up a new instance" do
        # sigh.

        max       = 4
        format    = :json
        out       = "/tmp"
        listeners = [mock(AbstractListener, :update => nil)]
        log       = false
        features  = %w[a b]

        mock_queue = mock(WorkerQueue)
        mock_workers = Array.new(2) { |n| mock("Worker-#{n}") }

        Process.stub(:pid => 1234)

        WorkerQueue.should_receive(:new).with(max).and_return mock_queue
        Worker.should_receive(:new).with("a", :json, "/tmp/1234", []).and_return mock_workers[0]
        Worker.should_receive(:new).with("b", :json, "/tmp/1234", []).and_return mock_workers[1]

        mock_queue.should_receive(:add_observer).once.with listeners.first
        mock_queue.should_receive(:add).with mock_workers[0]
        mock_queue.should_receive(:add).with mock_workers[1]

        Runner.create(features,
          :max    => max,
          :notify => listeners,
          :format => format,
          :log    => false,
          :out    => out
        ).should be_kind_of(Runner)
      end

      it "creates and runs a new runner" do
        r = mock(Runner)
        Runner.should_receive(:create).with(%w[a b], {}).and_return(r)
        r.should_receive(:run)

        Runner.run(%w[a b])
      end
    end

    context "running" do
      let(:listener) { mock(AbstractListener, :update => nil) }
      let(:queue)    { mock(Queue, :has_failures? => false) }
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
    end

  end # Runner
end # CukeForker
