module CukeForker
  class Scenarios
    def self.all
      require 'cucumber/runtime/features_loader'

      scenario_line_logger = ScenarioLineLogger.new
      loader = Cucumber::Runtime::FeaturesLoader.new(feature_files, [], Gherkin::TagExpression.new([]))

      loader.features.each do |feature|
        feature.accept(scenario_line_logger)
      end

      scenario_line_logger.scenarios
    end

    def self.feature_files
      Dir.glob('**/**.feature')
    end
  end
end