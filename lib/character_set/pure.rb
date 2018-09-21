require 'character_set'
require 'character_set/ruby_fallback'

# CharacterSet::Pure uses only Ruby implementations.
# It is equal to CharacterSet if the C ext can't be loaded.
class CharacterSet
  class Pure
    prepend CharacterSet::RubyFallback
    prepend CharacterSet::SetMethodAdapters
    include CharacterSet::SharedMethods
    extend CharacterSet::PredefinedSets
  end
end
