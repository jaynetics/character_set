class CharacterSet
  module CoreExt
    module RegexpExt
      def character_set
        CharacterSet.of_regexp(self)
      end
    end
  end
end

::Regexp.send(:include, CharacterSet::CoreExt::RegexpExt)
