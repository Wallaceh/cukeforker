module CukeForker
  class AbstractListener

    def on_run_started

    end

    def on_worker_started(worker)

    end

    def on_worker_finished(worker)

    end

    def on_run_finished(failed)

    end

    def update(meth, *args)
      __send__(meth, *args)
    end

  end # AbstractListener
end # CukeForker
