#require 'cucumber/runtime/features_loader'

module CukeForker

  #
  # CukeForker::Scenarios.by_args(args)
  #
  # where 'args' is a String of cucumber options
  #
  # For example:
  # CukeForker::Scenarios.by_args(%W[-p my_profile -t @edition])
  # will return an array of scenarios and their line numbers that match
  # the tags specified in the cucumber profile 'my_profile' AND have the '@edition' tag
  #

  class Scenarios
    def self.by_args(args)
      options = Cucumber::Cli::Options.new(STDOUT, STDERR, :default_profile => 'default')
      tagged(options.parse!(args)[:tag_expressions])
    end

    def self.all
      any_tag = []
      tagged any_tag
    end

    def self.tagged(tags)
      tag_expression = Cucumber::Core::Gherkin::TagExpression.new(tags)
      scenario_line_logger = CukeForker::Formatters::ScenarioLineLogger.new(tag_expression)
      cuke("--no-color", "--require", "features", "--dry-run", feature_files)
      binding.pry

      # loader = Cucumber::Configuration.new({paths: feature_files})
      # loader.feature_files.each do |feature|
      #   feature = Cucumber::Core::Gherkin::AstBuilder.new(feature)
      #   binding.pry
      #   scenario_line_logger.visit_feature_element(feature)
      # end

      scenario_line_logger.scenarios
    end

    def self.cuke(*args)
      cuke_config = Cucumber::Cli::Configuration.new
      cuke_config.parse!(args)
      @cuke_runtime = Cucumber::Runtime.new(cuke_config)
    end

    def self.feature_files
      Dir.glob('**/**.feature')
    end
  end
end