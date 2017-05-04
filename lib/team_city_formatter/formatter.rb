require_relative 'logger'
require_relative 'models'

module TeamCityFormatter
  class Formatter
    def initialize(runtime, io, options)
      @logger = Logger.new(io)
      @feature = nil
      @exception = nil
      @scenario = nil
      @scenario_outline = nil
    end

    def before_feature(cuke_feature)
      @feature = Feature.new.tap do |x|
        x.name = "#{cuke_feature.keyword}: #{cuke_feature.name}"
      end

      @logger.test_suite_started(@feature.name)
    end

    def after_feature(cuke_feature)
      @logger.test_suite_finished(@feature.name)

      @feature = nil
    end

    # this method gets called before a scenario or scenario outline
    # we dispatch to our own more specific methods
    def before_feature_element(cuke_feature_element)
      if cuke_feature_element.is_a?(Cucumber::Core::Ast::Scenario)
        before_scenario(cuke_feature_element)
      elsif cuke_feature_element.is_a?(Cucumber::Core::Ast::ScenarioOutline)
        before_scenario_outline(cuke_feature_element)
      else
        raise("unsupported feature element `#{cuke_feature_element.class.name}`")
      end
    end

    # this method gets called after a scenario or scenario outline
    # we dispatch to our own more specific methods
    def after_feature_element(cuke_feature_element)
      if cuke_feature_element.is_a?(Cucumber::Formatter::LegacyApi::Ast::Scenario)
        after_scenario(cuke_feature_element)
      elsif cuke_feature_element.is_a?(Cucumber::Formatter::LegacyApi::Ast::ScenarioOutline)
        after_scenario_outline(cuke_feature_element)
      else
        raise("unsupported feature element `#{cuke_feature_element.class.name}`")
      end

      @exception = nil
      @scenario = nil
      @scenario_outline = nil
    end

    # this method is called before a scenario outline row OR step data table row
    def before_table_row(cuke_table_row)
      if cuke_table_row.is_a?(Cucumber::Formatter::LegacyApi::ExampleTableRow)
        is_not_header_row = (@scenario_outline.example_column_names != cuke_table_row.values)
        if is_not_header_row
          example = @scenario_outline.examples.find { |example| example.column_values == cuke_table_row.values }
          test_name = scenario_outline_test_name(@scenario_outline.name, example.column_values)
          @logger.test_started(test_name)
        end
      end
    end

    # this method is called after a scenario outline row OR step data table row
    def after_table_row(cuke_table_row)
      if cuke_table_row.is_a?(Cucumber::Formatter::LegacyApi::Ast::ExampleTableRow)
        is_not_header_row = (@scenario_outline.example_column_names != cuke_table_row.cells)
        if is_not_header_row
          # treat scenario-level exception as example exception
          # the exception could have been raised in a background section
          exception = (@exception || cuke_table_row.exception)
          example = @scenario_outline.examples.find { |example| example.column_values == cuke_table_row.cells }
          test_name = scenario_outline_test_name(@scenario_outline.name, example.column_values)
          if exception
            if exception.is_a? ::Cucumber::Pending
              @logger.test_ignored(test_name, 'Pending test')
            else
              @logger.test_failed(test_name, exception)
            end
          end
          @logger.test_finished(test_name)

          @exception = nil
        end
      end
    end

    def exception(exception, status)
      @exception = exception
    end

    private

    def before_scenario(cuke_scenario)
      @scenario = Scenario.new.tap do |x|
        x.name = "#{cuke_scenario.keyword}: #{cuke_scenario.name}"
      end
      @logger.test_started(@scenario.name)
    end

    def before_scenario_outline(cuke_scenario_outline)
      cuke_example_rows = cuke_scenario_outline.examples_tables.map(&:example_rows).flatten
      @scenario_outline = ScenarioOutline.new.tap do |x|
        x.name = "#{cuke_scenario_outline.keyword}: #{cuke_scenario_outline.name}"
        x.example_column_names = cuke_example_rows.first.send(:data).keys
        x.examples =
          cuke_example_rows.map do |example_row|
            example_row.send(:data).values
          end.map do |example_column_values|
            Example.new.tap do |x|
              x.column_values = example_column_values
            end
          end
      end
    end

    def after_scenario(cuke_scenario)
      test_name = @scenario.name
      if @exception
        if @exception.is_a? ::Cucumber::Pending
          @logger.test_ignored(test_name, 'Pending test')
        else
          @logger.test_failed_with_exception(test_name, @exception)
        end
      end
      # a background step previously failed and was reported the first time the failure happened
      if (cuke_scenario.status == :skipped) && (@exception == nil)
        @logger.test_failed(test_name, 'Background failure')
      end
      @logger.test_finished(test_name)
    end

    def after_scenario_outline(cuke_scenario_outline)
      # do nothing
    end

    def scenario_outline_test_name(scenario_outline_name, example_column_values)
      "#{scenario_outline_name} | #{example_column_values.join(' | ')} |"
    end
  end
end
