class CharacterSet
  module Writer
    class << self
      def write(codepoint_ranges, opts = {}, &block)
        content = codepoint_ranges.map do |range|
          if range.size > 2 && opts[:abbreviate] != false
            bounds = [range.min, range.max]
            bounds.map { |cp| write_codepoint(cp, opts, &block) }.join('-')
          else
            range.map { |cp| write_codepoint(cp, opts, &block) }.join
          end
        end.join
        opts[:in_brackets] ? "[#{content}]" : content
      end

      def write_codepoint(codepoint, opts = {}, &block)
        Character.new(codepoint).escape(opts, &block)
      end

      def write_surrogate_ranges(bmp_ranges, astral_ranges)
        astral_branches = surrogate_range_expressions(astral_ranges)
        bmp_set_with_alternatives(bmp_ranges, astral_branches)
      end

      def write_surrogate_alternation(bmp_ranges, astral_ranges)
        astral_branches = surrogate_pairs(astral_ranges)
        bmp_set_with_alternatives(bmp_ranges, astral_branches)
      end

      private

      def surrogate_range_expressions(astral_ranges)
        compressed_surrogate_range_pairs(astral_ranges).map do |hi_ranges, lo_ranges|
          [hi_ranges, lo_ranges].map do |ranges|
            use_brackets = ranges.size > 1 || ranges.first.size > 1
            write(ranges, format: :js, in_brackets: use_brackets)
          end.join
        end
      end

      def compressed_surrogate_range_pairs(astral_ranges)
        halves = astral_ranges.flat_map { |range| surrogate_half_ranges(range) }

        # compress high surrogate codepoint ranges with common low range half
        with_common_lo = halves.group_by(&:last).map do |lo_range, pairs|
          hi_ranges = pairs.map(&:first)
          compressed_hi_ranges = hi_ranges.each_with_object([]) do |range, arr|
            prev = arr.last
            if prev.nil? || prev.max + 1 < range.min # first or gap
              arr << range
            else # continuous codepoints, expand previous range
              arr[-1] = (prev.min)..(range.max)
            end
          end
          [compressed_hi_ranges, lo_range]
        end

        # compress low surrogate codepoint ranges with common high ranges
        with_common_lo.each_with_object({}) do |(hi_ranges, lo_range), hash|
          (hash[hi_ranges] ||= []) << lo_range
        end
      end

      def surrogate_half_ranges(astral_range)
        hi_min, lo_min = surrogate_pair_codepoints(astral_range.min)
        hi_max, lo_max = surrogate_pair_codepoints(astral_range.max)
        hi_count = 1 + hi_max - hi_min
        return [[hi_min..hi_min, lo_min..lo_max]] if hi_count == 1

        ranges = []

        # first high surrogate might be partially covered (if lo_min > 0xDC00)
        ranges << [hi_min..hi_min, lo_min..0xDFFF]

        # any high surrogates in between are fully covered
        ranges << [(hi_min + 1)..(hi_max - 1), 0xDC00..0xDFFF] if hi_count > 2

        # last high surrogate might be partially covered (if lo_max < 0xDFFF)
        ranges << [hi_max..hi_max, 0xDC00..lo_max]

        ranges
      end

      def surrogate_pair_codepoints(astral_codepoint)
        base = astral_codepoint - 0x10000
        high = base / 1024 + 0xD800
        low  = base % 1024 + 0xDC00
        [high, low]
      end

      def bmp_set_with_alternatives(bmp_ranges, alternatives)
        bmp_set = write(bmp_ranges, format: :js, in_brackets: true)
        return bmp_set if alternatives.empty? && bmp_ranges.any?

        "(?:#{((bmp_ranges.any? ? [bmp_set] : []) + alternatives).join('|')})"
      end

      def surrogate_pairs(astral_ranges)
        astral_ranges.flat_map { |range| range.map { |cp| surrogate_pair(cp) } }
      end

      def surrogate_pair(astral_codepoint)
        surrogate_pair_codepoints(astral_codepoint)
          .map { |half| write_codepoint(half, format: :js) }.join
      end
    end
  end
end
