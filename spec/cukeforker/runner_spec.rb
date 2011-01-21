require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe Runner do

    it "sets up a new instance" do
      features = %w[a b]
      listener = mock(AbstractListener)

#      Runner.new(:max => 2, :notify => listener)
    end

  end # Runner
end # CukeForker
