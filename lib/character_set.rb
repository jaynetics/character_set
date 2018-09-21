require 'character_set/character'
require 'character_set/expression_converter'
require 'character_set/parser'
require 'character_set/predefined_sets'
require 'character_set/set_method_adapters'
require 'character_set/shared_methods'
require 'character_set/version'
require 'character_set/writer'

class CharacterSet
  begin
    require 'character_set/character_set'
  rescue LoadError
    require 'character_set/ruby_fallback'
    prepend RubyFallback
  end
  prepend SetMethodAdapters
  include Enumerable
  include SharedMethods
  extend PredefinedSets
end
