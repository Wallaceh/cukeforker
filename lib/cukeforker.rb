unless RUBY_PLATFORM =~ /darwin|linux/
  raise "CukeForker only supported on *nix/MRI"
end


require "cucumber/cli/main"
require "vnctools"
require "fileutils"
require "observer"
require "ostruct"

module CukeForker
end

require 'cukeforker/abstract_listener'
require 'cukeforker/vnc_listener'
require 'cukeforker/logging_listener'
require 'cukeforker/worker'
require 'cukeforker/worker_queue'
require 'cukeforker/runner'
