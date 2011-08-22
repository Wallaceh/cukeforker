require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe ScenarioLineLogger do
    it "returns scenario names and line numbers for a scenario" do
      logger = ScenarioLineLogger.new

      feature = mock("Cucumber::Ast::Feature")
      feature_element = mock("Cucumber::Ast::Scenario")

      feature.should_receive(:file).twice.and_return('features/test1.feature')
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

      class FakeScenarioOutline
        def initialize
          @line = 4
        end
      end

      feature = mock("Cucumber::Ast::Feature")
      feature_element = FakeScenarioOutline.new

      feature.should_receive(:file).and_return('features/test1.feature')
      feature_element.should_receive(:feature).and_return(feature)

      logger.visit_feature_element(feature_element)

      logger.scenarios.length.should == 1
      logger.scenarios[0].should == "features/test1.feature:4"
    end
  end
end