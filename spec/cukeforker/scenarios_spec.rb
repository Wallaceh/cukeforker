require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe Scenarios do
    it "returns all scenarios and their line numbers" do
      feature_1 = Cucumber::FeatureFile.new("features/test1.feature")
      feature_2 = Cucumber::FeatureFile.new("features/test2.feature")

      feature_1.instance_variable_set(:@source,
        "Feature: test 1
          Scenario: test scenario 1
            Given nothing happens

          Scenario: test scenario 2
            Given nothing else happens")


      feature_2.instance_variable_set(:@source,
        "Feature: test 2

          Scenario: test scenario 3
            Given nothing happens

          Scenario Outline: test scenario 4
            Given nothing happens
            Examples:
            | nothing |
            | 1       |
        ")

      Cucumber::FeatureFile.stub!(:new).with("features/test1.feature").and_return(feature_1)
      Cucumber::FeatureFile.stub!(:new).with("features/test2.feature").and_return(feature_2)

      Scenarios.stub!(:feature_files).and_return(['features/test1.feature', 'features/test2.feature'])

      all_scenarios = Scenarios.all

      all_scenarios.length.should == 4
      all_scenarios[0].should == "features/test1.feature:2"
      all_scenarios[1].should == "features/test1.feature:5"
      all_scenarios[2].should == "features/test2.feature:3"
      all_scenarios[3].should == "features/test2.feature:6"
    end

    it "returns all scenarios and their line numbers" do
      feature_1 = Cucumber::FeatureFile.new("features/test1.feature")

      feature_1.instance_variable_set(:@source,
        "Feature: test 1
          @find_me
          Scenario: test scenario 1
            Given nothing happens

          Scenario: test scenario 2
            Given nothing else happens")

      Cucumber::FeatureFile.stub!(:new).with("features/test1.feature").and_return(feature_1)

      Scenarios.stub!(:feature_files).and_return(['features/test1.feature'])

      all_scenarios = Scenarios.by_args(%W[-t @find_me])

      all_scenarios.length.should == 1
      all_scenarios[0].should == "features/test1.feature:3"
    end
  end
end