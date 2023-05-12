lib = File.expand_path('../lib', __FILE__)
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

  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.require_paths = ['lib']

  s.extensions  = %w[ext/character_set/extconf.rb]

  s.required_ruby_version = '>= 2.1.0'
end
