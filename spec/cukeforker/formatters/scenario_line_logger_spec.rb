require File.expand_path("../../../spec_helper", __FILE__)
require 'cucumber/core/ast/scenario_outline'

module CukeForker::Formatters
  describe ScenarioLineLogger do
    it "returns scenario names and line numbers for a scenario" do
      logger = ScenarioLineLogger.new

      feature = double("Cucumber::Core::Ast::Feature")
      feature_element = double("Cucumber::Core::Ast::Scenario")

      feature.should_receive(:file).twice.and_return('features/test1.feature')
      feature_element.should_receive(:source_tags).twice.and_return('')
      feature_element.should_receive(:feature).twice.and_return(feature)
      feature_element.should_receive(:line).and_return(3)
      feature_element.should_receive(:line).and_return(6)

      logger.visit_feature_element(feature_element)
      logger.visit_feature_element(feature_element)

      logger.scenarios.length.should == 2
      logger.scenarios[0].should == "features/test1.feature:3"
      logger.scenarios[1].should == "features/test1.feature:6"
    end

    it "returns scenario names and line numbers for a scenario outline" do
      logger = ScenarioLineLogger.new

      feature = double("Cucumber::Core::Ast::Feature")
      location = double("Cucumber::Core::Ast::Location", :line => 4)
      feature_element = Cucumber::Core::Ast::ScenarioOutline.new(*Array.new(8) {|a| double(a, :each => true) })
      feature_element.stub(:location => location)

      feature.should_receive(:file).and_return('features/test1.feature')
      feature_element.should_receive(:source_tags).and_return('')
      feature_element.should_receive(:feature).and_return(feature)

      logger.visit_feature_element(feature_element)

      logger.scenarios.length.should == 1
      logger.scenarios[0].should == "features/test1.feature:4"
    end
  end
end
