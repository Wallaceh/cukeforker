require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe VncServer do

    context "managing new displays" do
      let(:server) { VncServer.new }

      it "starts a new server" do
        server.should_receive(:`).with("tightvncserver 2>&1").and_return("desktop is #{Socket.gethostname}:1")
        server.start
        server.display.should == ":1"
      end

      it "stops the server" do
        server.should_receive(:`).with("tightvncserver -kill :5 2>&1")
        server.stub :display => ":5"
        server.stop
      end

      it "raises VncServer::Error if the server could not be started" do
        server.should_receive(:`).and_return("oops")
        server.stub :last_status => mock(:success? => false)

        lambda { server.start }.should raise_error(VncServer::Error, /oops/)
      end
    end

    context "controlling an existing display" do
      let(:server) { VncServer.new ":5" }

      it "starts the server on the given display" do
        server.should_receive(:`).with("tightvncserver :5 2>&1").and_return("desktop is #{Socket.gethostname}:5")
        server.start
        server.display.should == ":5"
      end
    end

    it "returns an instance for all existing displays" do
      Dir.stub(:[]).and_return [".vnc/qa1:1.pid", ".vnc/qa1:2.pid", ".vnc/qa1:3.pid"]

      all = VncServer.all
      all.size.should == 3
      all.map { |e| e.display }.should == [":1", ":2", ":3"]
    end

  end # VncServer
end # CukeForker
