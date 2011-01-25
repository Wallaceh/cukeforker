module CukeForker
  class AbstractListener

    def on_run_starting
    end

    def on_worker_starting(worker)
    end

    def on_worker_finished(worker)
    end

    def on_worker_forked(worker)
    end

    def on_run_interrupted
    end

    def on_run_finished(failed)
    end

    def on_display_fetched(server)
    end

    def on_display_released(server)
    end

    def on_display_starting(server)
    end

    def on_display_stopping(server)
    end

    def on_eta(time, remaining, finished)
    end

    def update(meth, *args)
      __send__(meth, *args)
    end

  end # AbstractListener
end # CukeForker
