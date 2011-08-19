require File.expand_path("../../spec_helper", __FILE__)
module CukeForker
  class ScenarioLineLogger
    attr_reader :scenarios

    def initialize
      @scenarios = []
    end

    def visit_feature_element(feature_element)
      @scenarios <<  "#{feature_element.feature.file}:#{feature_element.line}"
    end

    def method_missing(*args)
    end
  end
end

module CukeForker
  #describe Scenarios do
  #  it "returns all scenarios and their line numbers" do
  #    test_file_one = "Feature: Test File One
  #
  #    Scenario: Test Scenario 1
  #      Given Placeholder Scenario
  #
  #    Scenario: Test Scenario 2
  #      Given Placeholder scenario
  #    "
  #
  #    test_file_two = "Feature: Test File Two
  #
  #
  #    Scenario: Test Scenario 3
  #      Given Placeholder scenario"
  #    all_scenarios = Scenarios.all
  #
  #
  #    #Cucumber::FeatureFile.should_receive(:new).with('features/test1.feature')
  #    file = Cucumber::FeatureFile.new("features/test1.feature", test_file_one)
  #    ast = file.parse([], {})
  #    visitor = FeatureVisitor.new
  #    ast.accept visitor
  #    p visitor.scenarios
  #    #p ast.next_feature_element ''
  #
  #    all_scenarios.length.should == 3
  #    all_scenarios[0].should == "features/test1.feature:3"
  #    all_scenarios[1].should == "features/test1.feature:6"
  #    all_scenarios[2].should == "features/test2.feature:4"
  #  end
  #end

  describe ScenarioLineLogger do
    it "returns scenario names and line numbers" do
      logger = ScenarioLineLogger.new

      feature_object = mock("Cucumber feature object")
      feature_element = mock("Cucumber AST Feature Element")

      feature_object.should_receive(:file).twice.and_return('features/test1.feature')
      feature_element.should_receive(:feature).twice.and_return(feature_object)
      feature_element.should_receive(:line).and_return(3)
      feature_element.should_receive(:line).and_return(6)

      logger.visit_feature_element(feature_element)
      logger.visit_feature_element(feature_element)

      logger.scenarios.length.should == 2
      logger.scenarios[0].should == "features/test1.feature:3"
      logger.scenarios[1].should == "features/test1.feature:6"
    end
  end
end