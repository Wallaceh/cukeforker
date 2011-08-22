module CukeForker
  class ScenarioLineLogger
    attr_reader :scenarios

    def initialize
      @scenarios = []
    end

    def visit_feature_element(feature_element)
      if feature_element.respond_to? :line
        @scenarios <<  "#{feature_element.feature.file}:#{feature_element.line}"
      else
        @scenarios <<  "#{feature_element.feature.file}:#{feature_element.instance_variable_get(:@line)}"
      end
    end

    def method_missing(*args)
    end
  end
end