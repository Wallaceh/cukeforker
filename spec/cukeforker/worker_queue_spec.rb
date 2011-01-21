require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe WorkerQueue do
    let(:workers) { Array.new(5) { |n| mock("Worker-#{n}") } }
    let(:queue) { WorkerQueue.new(3) }

    it "adds an item to the queue" do
      queue.should_not be_backed_up
      queue.add mock(Worker)
      queue.should be_backed_up
    end

    it "starts up to the max number of workers" do
      queue.should_not be_full

      workers.each do |w|
        queue.add w
      end

      workers[0].should_receive(:start)
      workers[1].should_receive(:start)
      workers[2].should_receive(:start)

      queue.fill

      queue.size.should == 3
      queue.should be_full
      queue.should be_backed_up
    end

    it "removes finished workers from the queue" do
      workers.each do |w|
        w.should_receive(:start)
        queue.add w
      end

      queue.fill

      workers[0].stub!(:finished? => true)
      workers[1].stub!(:finished? => true)
      workers[2].stub!(:finished? => false)

      queue.poll

      queue.should_not be_full
      queue.size.should == 1

      queue.fill

      queue.should be_full
    end

    it "notifies observers when workers are started or finished" do
      listener = AbstractListener.new
      queue.add_observer listener

      workers.each do |w|
        queue.add w
      end

      workers[0].stub(:start => nil, :finished? => true)
      workers[1].stub(:start => nil, :finished? => true)
      workers[2].stub(:start => nil, :finished? => false)

      listener.should_receive(:on_worker_starting).exactly(3).times
      queue.fill

      listener.should_receive(:on_worker_finished).exactly(2).times
      queue.poll
    end

  end # WorkerQueue
end # CukeForker
