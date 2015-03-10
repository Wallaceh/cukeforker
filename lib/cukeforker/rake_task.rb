require 'rake'
require 'rake/tasklib'

module CukeForker
  class RakeTask < Rake::TaskLib
    attr_accessor :name
    attr_accessor :verbose
    attr_accessor :features
    attr_accessor :extra_args

    def initialize(*args, &task_block)
      setup_ivars(args)

      desc 'Run CukeForker' unless ::Rake.application.last_comment

      task(name, *args) do |_, task_args|
        RakeFileUtils.send(:verbose, verbose) do
          if task_block
            task_block.call(*[self, task_args].slice(0, task_block.arity))
          end

          run_cukeforker
        end
      end
    end

    def setup_ivars(args)
      @name = args.shift || :cukeforker

      split = args.index("--")
      if split
        @extra_args = args[0..(split-1)]
        @features = args[(split+1)..-1]
      end
    end

    def run_cukeforker
      unless CukeForker::Runner.run(@features, :extra_args => @extra_args)
        raise 'Test failures'
      end
    end
  end
end
