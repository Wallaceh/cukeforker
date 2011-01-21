require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe VncServerPool do
    let(:pool)  { VncServerPool.new(3, SpecHelper::FakeVnc) }

    it "creates 3 instances of the given display class" do
      SpecHelper::FakeVnc.should_receive(:new).exactly(3).times

      pool = VncServerPool.new(3, SpecHelper::FakeVnc)
      pool.size.should == 3
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

    it "can stop the pool" do
      mock_server = mock(VncServer)

      pool.stub(:running => [mock_server])
      mock_server.should_receive(:stop)

      pool.stop
    end

    it "raises a TooManyDisplaysError if the pool is over capacity" do
      lambda { pool.release "foo" }.should raise_error(VncServerPool::TooManyDisplaysError)
    end

    it "raises a OutOfDisplaysError if the pool is empty" do
      3.times { pool.get }
      lambda { pool.get }.should raise_error(VncServerPool::OutOfDisplaysError)
    end

    it "notifies observers" do
      server   = mock(VncServer, :start => nil, :stop => nil)
      observer = mock(AbstractListener)

      SpecHelper::FakeVnc.stub :new => server

      observer.should_receive(:update).with :on_display_fetched , server
      observer.should_receive(:update).with :on_display_released, server
      observer.should_receive(:update).with :on_display_starting, server
      observer.should_receive(:update).with :on_display_stopping , server

      pool.add_observer observer

      pool.release pool.get
      pool.stop
    end

  end # VncServerPool
end # CukeForker
