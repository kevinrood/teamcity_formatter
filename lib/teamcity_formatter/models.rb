module TeamCityFormatter
  class Feature
    attr_accessor :name
  end

  class Scenario
    attr_accessor :name
  end

  class ScenarioOutline
    attr_accessor :name, :example_column_names, :examples
  end

  class Example
    attr_accessor :column_values
  end
end
