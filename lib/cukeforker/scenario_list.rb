class ScenarioList
  attr_accessor :scenarios

  def scenarios
    @scenarios
  end

  def before_test_step(test_step)
  end

  def after_test_step(test_step, result)
  end

  def before_test_case(test_case)
  end

  def after_test_case(test_case, result)
    @scenarios ||= []
    @scenarios << [test_case.feature.file, test_case.location.line].join(':')
  end

  def done
  end

  # Cucumber 3.0+ API
  def test_step_started(test_step)
  end

  def test_step_finished(test_step, result)
  end

  def test_case_started(test_case)
  end

  def test_case_finished(test_case, result)
    after_test_case(test_case, result)
  end
end
