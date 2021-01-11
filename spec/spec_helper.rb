if ENV['CI'] && RUBY_VERSION.start_with?('2.7')
  require 'simplecov'
  SimpleCov.start

  ENV['CODECOV_TOKEN'] = '05e59458-baf5-48e5-9351-159d27ccf1f3'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'bundler/setup'
require 'character_set'
require 'character_set/pure'

Dir[File.join(__dir__, 'support', '*.rb')].sort.each { |file| require file }

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
