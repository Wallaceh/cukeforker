require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe Manager do
    let(:manager) { Manager.new(2) }

    it "queues a worker" do
      manager.queue mock(Worker)
    end

    it "knows if more work is pending" do
      manager.should_not be_pending
      manager.queue mock(Worker)
      manager.should be_pending
    end


  end # Master
end # CukeForker
