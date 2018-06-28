require 'character_set'
require 'character_set/ruby_fallback'

class CharacterSet
  class Pure < ::CharacterSet
    # equal to CharacterSet if that is pure (e.g. if loading C ext failed)
    unless ancestors.include?(RubyFallback)
      prepend CharacterSet::RubyFallback
      prepend CharacterSet::SetMethodAdapters
    end
  end
end
