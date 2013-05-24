require 'gherkin/tag_expression'
module CukeForker
  module Formatters
    class ScenarioLineLogger
      attr_reader :scenarios

      def initialize(tag_expression = Gherkin::TagExpression.new([]))
        @scenarios = []
        @tag_expression = tag_expression
      end

      def visit_feature_element(feature_element)
        if @tag_expression.evaluate(feature_element.source_tags)
          line_number = if feature_element.respond_to?(:line)
                          feature_element.line
                        else
                          feature_element.location.line
                        end

          @scenarios << [feature_element.feature.file, line_number].join(':')
        end
      end

      def method_missing(*args)
      end
    end
  end
end
