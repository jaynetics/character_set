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

  s.add_development_dependency 'benchmark-ips', '~> 2.7'
  s.add_development_dependency 'codecov', '~> 0.1'
  s.add_development_dependency 'get_process_mem', '~> 0.2.3'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rake-compiler', '~> 1.0'
  s.add_development_dependency 'range_compressor', '~> 1.0'
  s.add_development_dependency 'regexp_parser', '~> 1.3'
  s.add_development_dependency 'regexp_property_values', '~> 0.3.5'
  s.add_development_dependency 'rspec', '~> 3.8'
end
