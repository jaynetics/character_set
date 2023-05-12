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
      @__set = CharacterSet::RubyFallback::SortedSet.new
      super
    end
  end
end

if RUBY_PLATFORM[/java/i]
  # JRuby has sorted_set in the stdlib.
  require 'set'
  CharacterSet::RubyFallback::Set       = ::Set
  CharacterSet::RubyFallback::SortedSet = ::SortedSet
else
  # For other rubies, set/sorted_set are vendored due to dependency issues:
  #
  # - issues with default vs. installed gems such as [#2]
  # - issues with the sorted_set dependency rb_tree
  # - long-standing issues in recent versions of sorted_set
  #
  # The RubyFallback, and thus these set classes, are only used for testing,
  # and for exotic rubies which use neither C nor Java.
  require 'character_set/ruby_fallback/vendored_set_classes'
end
