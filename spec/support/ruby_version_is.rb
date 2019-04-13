def ruby_version_is(version)
  Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new(version)
end
