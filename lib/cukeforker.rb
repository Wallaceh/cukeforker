require "cucumber/cli/main"
require "fileutils"

module CukeForker
  TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

  def self.shutting_down?
    !!@shutting_down
  end

  def self.shutting_down!
    @shutting_down = true
  end

  def self.log
    @log ||= (
      log = Logger.new STDOUT
      log.datetime_format = TIME_FORMAT

      log
    )
  end

end

require 'cukeforker/manager'
require 'cukeforker/queue'
require 'cukeforker/vnc'
require 'cukeforker/worker'
require 'cukeforker/master'
