# TeamCity Formatter

Render cucumber output in the format expected by TeamCity. This formatter is compatible with cucumber 2.0

## Installation

Add this to your test suite's Gemfile:

    gem 'teamcity_formatter'

Then execute:

    $ bundle install

Or, install it directly:

    $ gem install teamcity_formatter

## Usage

Direct cucumber to use the formatter:

    $ cucumber -f TeamCityFormatter::Formatter

## Notes

Our overall goals in writing a cucumber formatter are:

1. Generate TeamCity output from a cucumber 2 test suite
1. Passing and failing test counts should match the same counts as the standard cucumber formatter

Cucumber elements are mapped simply to TeamCity test artifacts:

Cucumber                 | TeamCity
----                     | ---
Feature                  | TestSuite
Scenario                 | Test
Sceanrio Outline Example | Test

Test failures include the stack trace of the exception which triggered the failure.

## Features

### Support [parallel_cucumber](https://rubygems.org/gems/parallel_cucumber)

The formatter now includes a `flowId` attribute in output messages. `flowId` is the test runner process id.

### Pending Scenarios and Scenario Examples

Pending scenarios and scenario examples are logged as ignored tests.

## Acknowledgements

This gem drew some code from [`cucumber_teamcity`](https://github.com/ankurcha/cucumber_teamcity/). The `cucumber_teamcity` formatter is not compatible with Cucumber 2.

Also, though we did not use code from their project, JetBrains makes available some TeamCity-related code [here](https://github.com/JetBrains/intellij-plugins/tree/master/ruby-testing/src/rb/testing/patch/bdd/teamcity), which may be of interest to others researching TeamCity Cucumber formatters.

Thank you to contributors:

Contributor                                     | Contribution
---                                             | ---
[PositiveAlex](https://github.com/PositiveAlex) | Allow cucumber to use the formatter directly from the command line
[aklossrbh](https://github.com/aklossrbh)       | Support [parallel_cucumber](https://rubygems.org/gems/parallel_cucumber)
[gricsi](https://github.com/gricsi)             | Log pending scenarios and scenario examples as ignored tests

## License

Apache License, Version 2.0
