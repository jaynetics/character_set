require 'character_set/character'
require 'character_set/expression_converter'
require 'character_set/parser'
require 'character_set/predefined_sets'
require 'character_set/set_method_adapters'
require 'character_set/shared_methods'
require 'character_set/version'
require 'character_set/writer'

# A set of Unicode codepoints with engine-specific storage backends.
class CharacterSet
  begin
    if RUBY_ENGINE == 'jruby'
      require 'character_set/java'
    else
      require 'character_set/character_set' # C extension
    end
  rescue LoadError
    require 'character_set/ruby_fallback'
    prepend RubyFallback
  end
  prepend SetMethodAdapters
  include Enumerable
  include SharedMethods
  extend PredefinedSets
end
