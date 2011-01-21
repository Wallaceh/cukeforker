require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe VncListener do
    let(:server)    { mock(VncServer)       }
    let(:pool)      { mock(VncServerPool)   }
    let(:worker)    { mock(Worker)          }
    let(:listener)  { VncListener.new pool }

    it "fetches a display from the pool and assings it to the worker" do
      pool.should_receive(:get).and_return(server)
      worker.should_receive(:vnc=).with server

      listener.on_worker_starting worker
    end

    it "releases the display and removes it from the worker" do
      worker.should_receive(:vnc).and_return server
      pool.should_receive(:release).with server
      worker.should_receive(:vnc=).with(nil)

      listener.on_worker_finished worker
    end

  end # VncListenerServer
end # CukeForker
