class ScenarioList
  attr_accessor :scenarios

  @@scenarios ||= []

  def self.scenarios
    @@scenarios
  end

  def before_test_step(test_step)
  end

  def after_test_step(test_step, result)
  end

  def before_test_case(test_case)
  end

  def after_test_case(test_case, result)
    @@scenarios << [test_case.feature.file, test_case.location.line].join(':')
  end

  def done
  end
end