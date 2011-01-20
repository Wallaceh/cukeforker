$LOAD_PATH.unshift File.expand_path("../lib")
require 'cukeforker'

module CukeForker
  module SpecHelper
    class FakeVnc
    end
  end
end

RSpec.configure { |c|
  c.include CukeForker::SpecHelper
}
