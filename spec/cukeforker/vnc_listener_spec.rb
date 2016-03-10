require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe VncListener do
    let(:server) { double(VncTools::Server, :display => ":15") }
    let(:pool) { double(VncTools::ServerPool) }
    let(:worker) { double(Worker, :data => OpenStruct.new) }
    let(:listener) { VncListener.new pool }

    it "fetches a display from the pool and assings it to the worker" do
      pool.should_receive(:get).and_return(server)
      worker.data.should_receive(:vnc=).with server

      listener.on_worker_starting worker
    end

    it "releases the display and removes it from the worker" do
      worker.data.should_receive(:vnc).and_return server
      pool.should_receive(:release).with server
      worker.data.should_receive(:vnc=).with(nil)

      listener.on_worker_finished worker
    end

    it "stops the pool when the run finishes" do
      pool.should_receive(:stop)

      listener.on_run_finished(true)
    end

    it "sets DISPLAY after the worker is forked" do
      worker.data.should_receive(:vnc).and_return(server)
      ENV.should_receive(:[]=).with("DISPLAY", ":15")

      listener.on_worker_forked worker
    end
  end # VncListenerServer
end # CukeForker
