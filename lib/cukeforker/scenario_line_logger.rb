module CukeForker
  class Scenarios
    def self.all
      require 'cucumber/runtime/features_loader'
      #Cucumber::Runtime::FeaturesLoader.new()
       ["features/test1.feature:3", "features/test1.feature:6","features/test2.feature:4"]
    end
  end
end