lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'character_set/version'

Gem::Specification.new do |s|
  s.name          = 'character_set'
  s.version       = CharacterSet::VERSION
  s.authors       = ['Janosch Müller']
  s.email         = ['janosch84@gmail.com']

  s.summary       = 'Build, read, write and compare sets of Unicode codepoints.'
  s.homepage      = 'https://github.com/jaynetics/character_set'
  s.license       = 'MIT'

  gemspec = File.basename(__FILE__)
  s.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) || f.start_with?(*%w[bin/ spec/ tasks/ .git .github .gouteur .rspec BENCHMARK Gemfile])
    end
  end
  s.require_paths = ['lib']

  s.extensions    = %w[ext/character_set/extconf.rb]

  s.required_ruby_version = '>= 3.0.0'
end
