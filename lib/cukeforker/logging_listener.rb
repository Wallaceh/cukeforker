require "logger"

module CukeForker
  class LoggingListener < AbstractListener
    TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

    def on_run_starting
      log.info "[            run                ] starting"
    end

    def on_worker_starting(worker)
      log.info "[            worker:#{worker.id}           ] starting: #{worker.feature}"
    end

    def on_worker_finished(worker)
      log.info "[            worker:#{worker.id}           ] finished: #{worker.feature}"
    end

    def on_run_finished(failed)
      log.info "[            run                ] finished"
    end

    def on_run_interrupted
      puts "\n"
      log.info "[            run                ] interrupted"
    end

    def log
      @log ||= (
        log = Logger.new $stdout
        log.datetime_format = TIME_FORMAT

        log
      )
    end
  end # LoggingListener

end # CukeForker