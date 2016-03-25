require "logger"

module CukeForker
  class LoggingListener < AbstractListener
    TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

    def initialize(io = STDOUT)
      @io = io
      @running = []
    end

    def on_run_starting
      log.info "[    run           ] starting"
    end

    def on_worker_starting(worker)
      @running << worker.id
      log.info "[    worker  #{worker.id.to_s.ljust 3}   ] starting: #{worker.feature}"
    end

    def on_worker_forked(worker)
      log.info "[    worker  #{worker.id.to_s.ljust 3}   ] forked  : #{worker.feature}"
    end

    def on_worker_finished(worker)
      @running.delete(worker.id)
      log.info "[    worker  #{worker.id.to_s.ljust 3}   ] #{status_string(worker.failed?).ljust(8)}: #{worker.feature}"
    end

    def on_run_finished(failed)
      log.info "[    run           ] finished, #{status_string failed}"
    end

    def on_run_interrupted
      puts "\n"
      log.info "[    run           ] interrupted - please wait"
    end

    def on_display_fetched(server)
      log.info "[    display #{server.display.to_s.ljust(3)}   ] fetched"
    end

    def on_display_released(server)
      log.info "[    display #{server.display.to_s.ljust(3)}   ] released"
    end

    def on_display_starting(server)
      log.info "[    display #{server.display.to_s.ljust(3)}   ] starting"
    end

    def on_display_stopping(server)
      log.info "[    display #{server.display.to_s.ljust(3)}   ] stopping"
    end

    def on_eta(eta, remaining, finished)
      counts = "#{remaining}/#{finished}".ljust(6)
      log.info "[    eta     #{counts}] #{eta.strftime TIME_FORMAT}"
      log.info "[    running       ] #{@running}"
    end

    private

    def status_string(failed)
      failed ? 'failed' : 'passed'
    end

    def log
      @log ||= (
        log = Logger.new @io
        log.datetime_format = TIME_FORMAT

        log
      )
    end
  end # LoggingListener

end # CukeForker