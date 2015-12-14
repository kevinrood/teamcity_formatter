require 'date'

VERSION = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |gem|
  gem.name        = 'teamcity_formatter'
  gem.version     = VERSION
  gem.date        = Date.today.strftime('%Y-%m-%d')
  gem.summary     = 'TeamCity cucumber output formatter'
  gem.description = 'Render cucumber test output in a format consumable by TeamCity'
  gem.author      = ['Kevin Rood']
  gem.files       = `git ls-files LICENSE readme.md *.rb`.split($/)
  gem.homepage    = 'https://github.com/kevinrood/teamcity_formatter'
  gem.license     = 'Apache-2.0'

  gem.add_runtime_dependency('cucumber', '>= 2.0')
end
