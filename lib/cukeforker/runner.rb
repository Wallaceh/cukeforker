module CukeForker
  class Runner

   def self.run(*args)
     create(*args).run
   end

   def self.create(features, opts = {})
    new WorkerQueue.new(features)
        DisplayPool.new(opts[:max])
   end

  end
end