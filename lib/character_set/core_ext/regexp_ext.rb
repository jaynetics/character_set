class CharacterSet
  module CoreExt
    module RegexpExt
      def character_set
        CharacterSet.of_regexp(self)
      end
    end
  end
end

::Regexp.instance_eval { include CharacterSet::CoreExt::RegexpExt }
