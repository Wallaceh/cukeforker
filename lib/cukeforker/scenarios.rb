module CukeForker
  class Scenarios
    def self.all(tags = [])
      require 'cucumber/runtime/features_loader'

      tag_expression = Gherkin::TagExpression.new(tags)
      scenario_line_logger = ScenarioLineLogger.new(tag_expression)
      loader = Cucumber::Runtime::FeaturesLoader.new(feature_files, [], tag_expression)

      loader.features.each do |feature|
        feature.accept(scenario_line_logger)
      end

      scenario_line_logger.scenarios
    end

    def self.feature_files
      Dir.glob('**/**.feature')
    end

    def self.by_args(args)
      options = Cucumber::Cli::Options.new(STDOUT, STDERR, :default_profile => 'default')
      all(options.parse!(args.split(' '))[:tag_expressions])
    end
  end
end