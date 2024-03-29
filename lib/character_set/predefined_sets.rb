class CharacterSet
  module PredefinedSets
    Dir[File.join(__dir__, 'predefined_sets', '*.cps')].each do |path|
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

    alias all                      any
    alias ascii_letters            ascii_letter
    alias basic_multilingual_plane bmp
    alias blank                    whitespace
    alias invalid                  surrogate
    alias valid                    unicode

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
  end
end
