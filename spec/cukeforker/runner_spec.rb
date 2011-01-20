require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe Runner do

    # From the outside:
    #
    # Runner.run(features, opts)
    #
    # where 'features' is an Array of file:line
    # and 'opts' is a Hash of options:
    #
    #   :max        => max          number of workers (default: 2)
    #   :vnc        => true/false   children are launched with DISPLAY set from a VNC server pool,
    #                               where the size of the pool is equal to :max
    #   :notify     => object       (or array of objects) implementing the AbstractListener API
    #   :out        => path         directory to dump output to (default: current working dir)
    #   :log        => true/false   wether or not to log to stdout (default: true)
    #

    it "sets up a new instance" do
      features = %w[a b]
      listener = mock(AbstractListener)

#      Runner.new(:max => 2, :notify => listener)
    end

  end # Runner
end # CukeForker
