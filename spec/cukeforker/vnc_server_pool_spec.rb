require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe VncServerPool do
    let(:pool)  { VncServerPool.new(3, SpecHelper::FakeVnc) }

    it "creates 3 instances of the given display class" do
      SpecHelper::FakeVnc.should_receive(:new).exactly(3).times

      pool = VncServerPool.new(3, SpecHelper::FakeVnc)
      pool.size.should == 3
    end

    it "launches the displays" do
      servers = [mock("VncServer"), mock("VncServer"), mock("VncServer")]
      SpecHelper::FakeVnc.should_receive(:new).exactly(3).times.and_return(*servers)

      servers.each { |s| s.should_receive(:start) }
      pool.launch
    end

    it "can fetch a server from the pool" do
      pool.get.should be_kind_of(SpecHelper::FakeVnc)
      pool.size.should == 2
    end

    it "can release a server" do
      obj = pool.get
      pool.size.should == 2

      pool.release obj
    end

    it "raises a TooManyDisplaysError if the pool is over capacity" do
      lambda { pool.release "foo" }.should raise_error(VncServerPool::TooManyDisplaysError)
    end

    it "raises a OutOfDisplaysError if the pool is empty" do
      3.times { pool.get }
      lambda { pool.get }.should raise_error(VncServerPool::OutOfDisplaysError)
    end

  end # VncServerPool
end # CukeForker
