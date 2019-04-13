require 'bundler/setup'
require 'character_set'
require 'character_set/pure'

require_relative 'support/ruby_version_is'

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
