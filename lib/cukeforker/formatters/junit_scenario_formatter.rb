require 'cucumber/formatter/junit'

module CukeForker
  module Formatters
    class JunitScenarioFormatter < Cucumber::Formatter::Junit
      def feature_result_filename(feature_file)
        File.join(@reportdir, "TEST-#{basename(feature_file)}.xml")
      end

      def after_feature(feature)
        # do nothing
      end

      def feature_element_line_number(feature_element)
        if feature_element.respond_to? :line
          feature_element.line
        else
          feature_element.instance_variable_get(:@line)
        end
      end

      def end_feature(feature_element)
        @testsuite = Builder::XmlMarkup.new(:indent => 2)
        @testsuite.instruct!
        @testsuite.testsuite(
          :failures => @failures,
          :errors => @errors,
          :skipped => @skipped,
          :tests => @tests,
          :time => "%.6f" % @time,
          :name => @feature_name ) do
          @testsuite << @builder.target!
        end

        line_number = feature_element_line_number(feature_element)
        write_file(feature_result_filename(feature_element.feature.file+"-#{line_number}"), @testsuite.target!)
      end
    end
  end
end