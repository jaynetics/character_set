if RUBY_VERSION.to_f >= 3.0 && !RUBY_PLATFORM[/java/i]
  require 'sorted_set'
else
  require 'set'
end
require 'character_set/ruby_fallback/set_methods'
require 'character_set/ruby_fallback/character_set_methods'

class CharacterSet
  module RubyFallback
    include CharacterSet::RubyFallback::SetMethods
    include CharacterSet::RubyFallback::CharacterSetMethods

    def self.prepended(klass)
      klass.extend CharacterSet::RubyFallback::CharacterSetMethods::ClassMethods
    end

    def initialize(enum = [])
      @__set = SortedSet.new
      super
    end
  end
end
