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
        if @tag_expression.eval feature_element.source_tag_names
          if feature_element.respond_to? :line
            @scenarios <<  "#{feature_element.feature.file}:#{feature_element.line}"
          else
            @scenarios <<  "#{feature_element.feature.file}:#{feature_element.instance_variable_get(:@line)}"
          end
        end
      end

      def method_missing(*args)
      end
    end
  end
end