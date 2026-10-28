# frozen_string_literal: false

# Invoked by java:smoke in a fresh process and isolated gem environment.
require 'character_set'
require 'character_set/pure'
require 'java'

expected_root = File.realpath(ARGV.fetch(0))
loaded_root = File.realpath(Gem.loaded_specs.fetch('character_set').full_gem_path)
abort 'CharacterSet was loaded outside the isolated gem environment' unless loaded_root.start_with?("#{expected_root}/")
unless CharacterSet.new.to_java.java_class.name == 'org.jaynetics.characterset.RubyCharacterSet'
  abort 'Java backend not active'
end
abort 'Unexpected Unicode range result' unless CharacterSet.from_ranges(0...0x110000).size == 0x110000

text = 'aü😋a'
set = CharacterSet['ü', '😋']
abort 'Unexpected count' unless set.count_in(text) == 2
abort 'Unexpected filtering' unless set.keep_in(text) == 'ü😋'
abort 'Unexpected casefold mappings' unless CharacterSet['K'].case_insensitive.to_a == %w[K k K].map(&:ord).sort
abort 'Unexpected mutation identity' unless set.delete_in!(text).equal?(text) && text == 'aa'

puts "Installed Java gem verified: #{RUBY_DESCRIPTION}"
