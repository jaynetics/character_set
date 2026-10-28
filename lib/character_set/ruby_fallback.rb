require 'character_set/ruby_fallback/set_methods'
require 'character_set/ruby_fallback/character_set_methods'

class CharacterSet
  # The RubyFallback is used by non-standard Rubies that can't use
  # the C extension. It is tested in the specs via CharacterSet::Pure.
  module RubyFallback
    include CharacterSet::RubyFallback::SetMethods
    include CharacterSet::RubyFallback::CharacterSetMethods

    def self.prepended(klass)
      klass.extend CharacterSet::RubyFallback::CharacterSetMethods::ClassMethods
    end

    def initialize(enum = [])
      @__hash = {}
      @__keys = nil
      super
    end
  end
end
