class CharacterSet
  module PredefinedSets
    sets = Dir[File.join(__dir__, 'predefined_sets', '*.cps')]

    sets.each do |path|
      set_name = File.basename(path, '.cps')

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{set_name}
          @#{set_name} ||= build_from_cps_file('#{path}').freeze
        end

        def non_#{set_name}
          @non_#{set_name} ||= build_from_cps_file('#{path}').inversion.freeze
        end
      RUBY
    end

    def build_from_cps_file(path)
      if defined?(Ractor) && Ractor.current != Ractor.main
        raise <<-EOS.gsub(/^ */, '')
          CharacterSet's predefined sets are lazy-loaded.
          Pre-load them to use them in Ractors. E.g.:

          CharacterSet.ascii # pre-load
          Ractor.new { CharacterSet.ascii.size }.take # => 128
          Ractor.new { 'abc'.keep_character_set(:ascii) }.take # => 'abc'
        EOS
      end

      File.readlines(path).inject(new) do |set, line|
        range_start, range_end = line.split(',')
        set.merge((range_start.to_i(16))..(range_end.to_i(16)))
      end
    end

    aliases = {
      all:                      :any,
      ascii_letters:            :ascii_letter,
      basic_multilingual_plane: :bmp,
      blank:                    :whitespace,
      invalid:                  :surrogate,
      us_ascii:                 :ascii,
      utf_8:                    :unicode,
      utf_16:                   :unicode,
      utf_16be:                 :unicode,
      utf_16le:                 :unicode,
      utf_32:                   :unicode,
      valid:                    :unicode,
    }

    aliases.each { |from, to| alias_method(from, to) }

    names = sets.flat_map do |path|
      set_name = File.basename(path, '.cps')
      [set_name.to_sym, "non_#{set_name}".to_sym]
    end + aliases.keys

    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def predefined_names
        #{names}
      end
    RUBY
  end
end
