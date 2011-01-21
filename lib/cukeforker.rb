unless RUBY_PLATFORM =~ /darwin|linux/
  raise "CukeForker only supported on *nix/MRI"
end


require "cucumber/cli/main"
require "fileutils"
require "observer"

module CukeForker
end

require 'cukeforker/vnc_server_pool'
require 'cukeforker/vnc_server'
require 'cukeforker/abstract_listener'
require 'cukeforker/logging_listener'
require 'cukeforker/worker'
require 'cukeforker/worker_queue'
require 'cukeforker/runner'
