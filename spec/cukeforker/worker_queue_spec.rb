require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe WorkerQueue do
    let(:workers) { Array.new(5) { |n| double("Worker-#{n}") } }
    let(:queue) { WorkerQueue.new(3, 0, false) }


    it "adds an item to the queue" do
      queue.should_not be_backed_up
      queue.add workers.first
      queue.should be_backed_up
    end

    it "starts up to the max number of workers" do
      queue.should_not be_full
      queue.should be_empty

      workers.each { |w| queue.add w }

      workers[0].should_receive(:start)
      workers[1].should_receive(:start)
      workers[2].should_receive(:start)

      queue.fill

      queue.size.should == 3
      queue.should be_full
      queue.should be_backed_up
    end

    it "is unlimited if max workers = 0" do
      unlimited_queue = WorkerQueue.new(0, 0)

      workers.each { |w| queue.add double.as_null_object }

      unlimited_queue.fill
      unlimited_queue.should_not be_full
      unlimited_queue.should_not be_backed_up
    end

    it "raises if max workers is negative" do
      expect { WorkerQueue.new(-1) }.to raise_error(ArgumentError)
    end

    it "removes finished workers from the queue" do
      workers.each do |w|
        w.should_receive(:start)
        queue.add w
      end

      queue.fill

      workers[0].stub(:finished? => true, :failed? => false)
      workers[1].stub(:finished? => true, :failed? => false)
      workers[2].stub(:finished? => false, :failed? => false)

      queue.poll

      queue.should_not be_full
      queue.size.should == 1

      queue.fill

      queue.should be_full
    end

    it "notifies observers when workers are started or finished" do
      listener = AbstractListener.new
      queue.add_observer listener

      workers.each { |w| queue.add w }

      workers[0].stub(:start => nil, :finished? => true, :failed? => false)
      workers[1].stub(:start => nil, :finished? => true, :failed? => false)
      workers[2].stub(:start => nil, :finished? => false, :failed? => false)

      listener.should_receive(:on_worker_starting).exactly(3).times
      queue.fill

      listener.should_receive(:on_worker_finished).exactly(2).times
      queue.poll
    end

    it "adds observers to pending workers" do
      listener = AbstractListener.new

      workers.each { |w|
        w.should_receive(:add_observer).with(listener)
        queue.add w
      }

      queue.add_observer listener
    end

    it "knows if any of the workers failed" do
      workers.each { |w| queue.add w }

      workers[0].stub(:start => nil, :finished? => true, :failed? => true)
      workers[1].stub(:start => nil, :finished? => true, :failed? => false)
      workers[2].stub(:start => nil, :finished? => true, :failed? => false)

      queue.fill
      queue.poll

      queue.should have_failures
    end

    it "processes the queue until no longer backed up" do
      workers.each { |w| queue.add w }

      workers[0].stub(:start => nil, :finished? => true, :failed? => true)
      workers[1].stub(:start => nil, :finished? => true, :failed? => false)
      workers[2].stub(:start => nil, :finished? => true, :failed? => false)
      workers[3].stub(:start => nil, :finished? => true, :failed? => false)
      workers[4].stub(:start => nil, :finished? => true, :failed? => false)

      queue.process

      queue.should_not be_backed_up
      queue.should_not be_full
    end

    it "polls until all workers are finished" do
      queue.stub :start_time => Time.now
      workers[0..2].each { |w| queue.add w }

      workers[0].stub(:start => nil, :failed? => false)
      workers[1].stub(:start => nil, :failed? => false)
      workers[2].stub(:start => nil, :failed? => false)

      workers[0].should_receive(:finished?).twice.and_return false, true
      workers[1].should_receive(:finished?).twice.and_return false, true
      workers[2].should_receive(:finished?).twice.and_return false, true

      queue.fill
      queue.should_not be_backed_up
      queue.should be_full

      queue.wait_until_finished
    end

    it "estimates the time left" do
      now = Time.now
      seconds_per_child = 60

      queue.stub :start_time => now
      Time.stub :now => now + seconds_per_child

      workers[0..2].each { |w| queue.add w }

      workers[0].stub(:start => nil, :finished? => true, :failed? => false)
      workers[1].stub(:start => nil, :finished? => false, :failed? => false)
      workers[2].stub(:start => nil, :finished? => false, :failed? => false)

      queue.fill
      queue.poll
      queue.eta.should == [Time.now + seconds_per_child*2, 2, 1]
    end

    context "with fail fast enabled" do
      let(:workers) { Array.new(10) { |n| double("Worker-#{n}") } }
      let(:queue) { WorkerQueue.new(3, 0, true) }

      it "should exit after the first test failure" do
        queue.should be_empty

        workers.each { |w| queue.add w }

        workers[0].stub(:start => nil, :finished? => true, :failed? => false)
        workers[1].stub(:start => nil, :finished? => false, :failed? => false, :kill => nil)
        workers[2].stub(:start => nil, :finished? => false, :failed? => false, :kill => nil)
        queue.fill
        queue.poll

        workers[3].stub(:start => nil, :finished? => false, :failed? => true)
        queue.fill
        queue.poll

        workers[3].stub(:finished? => true)
        queue.fill
        queue.poll

        queue.should_not be_backed_up
        queue.should be_empty
        queue.instance_variable_get(:@finished).should == [workers[0], workers[3]]

        queue.should have_failures
      end
    end
  end # WorkerQueue
end # CukeForker
