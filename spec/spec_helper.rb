require 'bundler/setup'
Dir[File.join(__dir__, 'support', '*.rb')].sort.each { |file| require file }

if ENV['CI'] && RUBY_VERSION.start_with?('3.2')
  require 'simplecov'
  require 'simplecov-cobertura'
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  SimpleCov.start
end

require 'character_set'
require 'character_set/pure'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = [:expect, :should] # :should is for ruby-spec examples
  end

  config.mock_with :rspec do |c|
    c.syntax = [:expect, :should] # :should is for ruby-spec examples
  end
end

def sorted_set_class
  CharacterSet::RubyFallback::SortedSet
end
