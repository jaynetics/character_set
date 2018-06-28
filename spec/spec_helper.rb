require 'bundler/setup'
require 'character_set'
require 'character_set/pure'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  # config.disable_monkey_patching! # required for ruby-spec examples

  config.expect_with :rspec do |c|
    c.syntax = [:expect, :should] # :should is for ruby-spec examples
  end

  config.mock_with :rspec do |c|
    c.syntax = [:expect, :should] # :should is for ruby-spec examples
  end
end

def ruby_version_is(version)
  Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new(version)
end
