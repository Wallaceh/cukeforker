require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe Queue do

    context "creating" do
      it "takes a max size argument" do
        q = Queue.new(5)
        q.max.should == 5
      end
    end

    context "adding and removing" do
      let(:q) { Queue.new(3) }

      it "adds items" do
        q.add 1
        q.size.should == 1
      end

      it "removes items" do
        q.add 1
        q.remove 1
        q.size.should == 0
        q.should be_empty
      end

      it "raises Queue::Error when adding to a full queue" do
        q.add 1
        q.add 2
        q.add 3
        lambda { q.add 4 }.should raise_error(Queue::Error)
      end

      it "knows when the queue is full" do
        q.add 1
        q.add 2
        q.add 3

        q.should be_full
      end
    end

  end # Queue
end # CukeForker
