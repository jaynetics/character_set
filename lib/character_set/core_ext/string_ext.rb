class CharacterSet
  module CoreExt
    module StringExt
      def character_set
        CharacterSet.of(self)
      end

      def covered_by_character_set?(set)
        set.cover?(self)
      end

      def uses_character_set?(set)
        set.used_by?(self)
      end

      def delete_character_set(set)
        set.delete_in(self)
      end

      def delete_character_set!(set)
        set.delete_in!(self)
      end

      def keep_character_set(set)
        set.keep_in(self)
      end

      def keep_character_set!(set)
        set.keep_in!(self)
      end
    end
  end
end

::String.send(:include, CharacterSet::CoreExt::StringExt)
