class CharacterSet
  module Writer
    module_function

    def write(codepoint_ranges, opts = {}, &block)
      content = codepoint_ranges.map do |range|
        if range.size > 2 && opts[:abbreviate] != false
          range.minmax.map { |cp| Character.new(cp).escape(opts, &block) }.join('-')
        else
          range.map { |cp| Character.new(cp).escape(opts, &block) }.join
        end
      end.join
      opts[:in_brackets] ? "[#{content}]" : content
    end

    def write_surrogate_alternation(bmp_ranges, astral_ranges)
      bmp_set = write(bmp_ranges, format: :js, in_brackets: true)
      if astral_ranges.empty?
        bmp_set
      else
        surrogate_pairs = surrogate_pairs(astral_ranges)
        "(?:#{((bmp_ranges.any? ? [bmp_set] : []) + surrogate_pairs) * '|'})"
      end
    end

    def surrogate_pairs(astral_ranges)
      astral_ranges.flat_map { |range| range.map { |cp| surrogate_pair(cp) } }
    end

    def surrogate_pair(astral_codepoint)
      base = astral_codepoint - 0x10000
      high = ((base / 1024).floor + 0xD800).to_s(16)
      low  = (base % 1024 + 0xDC00).to_s(16)
      "\\u#{high}\\u#{low}"
    end
  end
end
