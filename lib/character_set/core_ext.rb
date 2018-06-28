require 'character_set'

class CharacterSet
  module CoreExt
    module StringExt
      def character_set
        CharacterSet.new(codepoints)
      end

      def covered_by?(character_set)
        character_set.cover?(self)
      end

      def uses?(character_set)
        character_set.used_by?(self)
      end
    end
  end
end

::String.send(:include, CharacterSet::CoreExt::StringExt)
