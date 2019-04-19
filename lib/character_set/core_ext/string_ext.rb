class CharacterSet
  module CoreExt
    module StringExt
      def character_set
        CharacterSet.of(self)
      end

      {
        count_by_character_set:    :count_in,
        covered_by_character_set?: :cover?,
        delete_character_set:      :delete_in,
        delete_character_set!:     :delete_in!,
        keep_character_set:        :keep_in,
        keep_character_set!:       :keep_in!,
        scan_by_character_set:     :scan,
        uses_character_set?:       :used_by?,
      }.each do |string_method, set_method|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{string_method}(arg)
            if arg.instance_of?(Symbol)
              CharacterSet.__send__(arg).#{set_method}(self)
            else
              arg.#{set_method}(self)
            end
          end
        RUBY
      end
    end
  end
end

::String.send(:include, CharacterSet::CoreExt::StringExt)
