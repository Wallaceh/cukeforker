require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe RecordingVncListener do
    let(:recorder)  { mock(VncTools::Recorder) }
    let(:listener)  { RecordingVncListener.new nil, :codec => "foo" }

    # TODO: yuck inheritance
  end # RecordingVncListener
end # CukeForker
