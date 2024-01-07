class CharacterSet
  module CoreExt
    module RegexpExt
      def character_set
        CharacterSet.of_regexp(self)
      end

      def covered_by_character_set?(other)
        other.superset?(character_set)
      end

      def uses_character_set?(other)
        other.intersect?(character_set)
      end
    end
  end
end

::Regexp.instance_eval { include CharacterSet::CoreExt::RegexpExt }
