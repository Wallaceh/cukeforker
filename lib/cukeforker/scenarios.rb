require 'cucumber/core'
require 'cucumber/core/filter'

module CukeForker
  class Scenarios
    include Cucumber::Core

    def self.all
      feature_files.each do |feature|
        source = CukeForker::NormalisedEncodingFile.read(feature)
        file = Cucumber::Core::Gherkin::Document.new(feature, source)
        self.new.execute([file], ScenarioList.new, [Cucumber::Core::Test::TagFilter.new(['@wallace'])])
      end
      ScenarioList.scenarios
    end

    def self.feature_files
      Dir.glob('**/**.feature')
    end
  end
end