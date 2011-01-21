module CukeForker
  class AbstractListener

    def on_run_starting
    end

    def on_worker_starting(worker)
    end

    def on_worker_finished(worker)
    end

    def on_run_interrupted
    end

    def on_run_finished(failed)
    end

    def on_display_fetched(id)
    end

    def on_display_released(id)
    end

    def update(meth, *args)
      __send__(meth, *args)
    end

  end # AbstractListener
end # CukeForker
