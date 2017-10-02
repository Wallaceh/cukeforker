require 'cucumber/core'
require 'cucumber/core/filter'

module CukeForker
  class Scenarios
    include Cucumber::Core

    def self.by_args(args)
      options = Cucumber::Cli::Options.new(STDOUT, STDERR, :default_profile => 'default')
      tagged(options.parse!(args)[:tag_expressions])
    end

    def self.all
      any_tag = []
      tagged any_tag
    end

    def self.tagged(tags)
      scenario_list = ScenarioList.new
      feature_files.each do |feature|
        source = CukeForker::NormalisedEncodingFile.read(feature)
        file = Cucumber::Core::Gherkin::Document.new(feature, source)
        filters = [Cucumber::Core::Test::TagFilter.new(tags)]
        if Cucumber::VERSION[0].to_i < 3
          self.new.execute([file], scenario_list, filters)
        else
          # For Cucumber 3.0+ API, we have to flip the last two parameters
          self.new.execute([file], filters, scenario_list)
        end
      end
      scenario_list.scenarios
    end

    def self.feature_files
      Dir.glob('**/**.feature')
    end
  end
end
