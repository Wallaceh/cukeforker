require 'rbconfig'
unless RbConfig::CONFIG['host_os'] =~ /darwin|linux/
  raise "CukeForker only supported on *nix/MRI"
end


require "cucumber/cli/main"
require "vnctools"
require "fileutils"
require "observer"
require "forwardable"
require "ostruct"

module CukeForker
end

require 'cukeforker/abstract_listener'
require 'cukeforker/vnc_listener'
require 'cukeforker/recording_vnc_listener'
require 'cukeforker/logging_listener'
require 'cukeforker/worker'
require 'cukeforker/worker_queue'
require 'cukeforker/runner'
require 'cukeforker/scenarios'

require 'cukeforker/formatters/scenario_line_logger'
require 'cukeforker/formatters/junit_scenario_formatter'