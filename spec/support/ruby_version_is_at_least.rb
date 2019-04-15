def ruby_version_is_at_least(version)
  Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new(version)
end
