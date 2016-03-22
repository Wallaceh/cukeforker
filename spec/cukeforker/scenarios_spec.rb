require File.expand_path("../../spec_helper", __FILE__)

module CukeForker
  describe Scenarios do
    it "returns all scenarios and their line numbers" do
      Scenarios.stub(:feature_files).and_return(['features/test1.feature', 'features/test2.feature'])
      allow(CukeForker::NormalisedEncodingFile).to receive(:read).with(/features\/test\d\.feature/).and_return(<<-GHERKIN)
      Feature: Test Feature

        Scenario: Test Scenario 1
          Given I do fake precondition
          When I do fake action
          Then I get fake assertions

        Scenario: Test Scenario 2
          Given I do fake precondition
          When I do fake action
          Then I get fake assertions
      GHERKIN

      all_scenarios = Scenarios.all

      all_scenarios.length.should == 4
      all_scenarios[0].should == "features/test1.feature:3"
      all_scenarios[1].should == "features/test1.feature:8"
      all_scenarios[2].should == "features/test2.feature:3"
      all_scenarios[3].should == "features/test2.feature:8"
    end

    it "returns all scenarios and their line numbers by tags" do
      Scenarios.stub(:feature_files).and_return(['features/test1.feature'])
      allow(CukeForker::NormalisedEncodingFile).to receive(:read).with('features/test1.feature').and_return(<<-GHERKIN)
      Feature: test 1
          @find_me
          Scenario: test scenario 1
            Given nothing happens

          Scenario: test scenario 2
            Given nothing else happens
      GHERKIN

      all_scenarios = Scenarios.by_args(%W[-t @find_me])

      all_scenarios.length.should == 1
      all_scenarios[0].should == "features/test1.feature:3"
    end

    it "returns all scenarios and their line numbers by multiple include tags" do
      Scenarios.stub(:feature_files).and_return(['features/test1.feature'])
      allow(CukeForker::NormalisedEncodingFile).to receive(:read).with('features/test1.feature').and_return(<<-GHERKIN)
      Feature: test 1
          @find_me
          Scenario: test scenario 1
            Given nothing happens

          @me_too
          Scenario: test scenario 2
            Given nothing else happens
      GHERKIN

      all_scenarios = Scenarios.by_args(%W[-t @find_me,@me_too])

      all_scenarios.length.should == 2
      all_scenarios[0].should == "features/test1.feature:3"
      all_scenarios[1].should == "features/test1.feature:7"
    end

    it "returns all scenarios and their line numbers by multiple and tags" do
      Scenarios.stub(:feature_files).and_return(['features/test1.feature'])
      allow(CukeForker::NormalisedEncodingFile).to receive(:read).with('features/test1.feature').and_return(<<-GHERKIN)
      Feature: test 1
          @find_me @me_too
          Scenario: test scenario 1
            Given nothing happens

          @me_too
          Scenario: test scenario 2
            Given nothing else happens
      GHERKIN

      all_scenarios = Scenarios.by_args(%W[-t @find_me -t @me_too])

      all_scenarios.length.should == 1
      all_scenarios[0].should == "features/test1.feature:3"
    end

    it "returns all scenarios and their line numbers by exclusion tag" do
      Scenarios.stub(:feature_files).and_return(['features/test1.feature'])
      allow(CukeForker::NormalisedEncodingFile).to receive(:read).with('features/test1.feature').and_return(<<-GHERKIN)
      Feature: test 1
          @find_me
          Scenario: test scenario 1
            Given nothing happens

          @me_too
          Scenario: test scenario 2
            Given nothing else happens
      GHERKIN

      all_scenarios = Scenarios.by_args(%W[-t ~@find_me])

      all_scenarios.length.should == 1
      all_scenarios[0].should == "features/test1.feature:7"
    end
  end
end

