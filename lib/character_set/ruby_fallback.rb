require 'character_set/ruby_fallback/set_methods'
require 'character_set/ruby_fallback/character_set_methods'
require 'character_set/ruby_fallback/vendored_set_classes'

class CharacterSet
  module RubyFallback
    include CharacterSet::RubyFallback::SetMethods
    include CharacterSet::RubyFallback::CharacterSetMethods

    def self.prepended(klass)
      klass.extend CharacterSet::RubyFallback::CharacterSetMethods::ClassMethods
    end

    def initialize(enum = [])
      @__set = CharacterSet::RubyFallback::SortedSet.new
      super
    end
  end
end
