class CharacterSet
  module RubyFallback
    module CharacterSetMethods
      module ClassMethods
        def from_ranges(*ranges)
          new(Array(ranges).flat_map(&:to_a))
        end

        def used_by(string)
          new(string.codepoints)
        end
      end

      def inversion(include_surrogates: false, upto: 0x10FFFF)
        new_set = self.class.new
        0.upto(upto) do |cp|
          next unless include_surrogates || cp > 0xDFFF || cp < 0xD800
          new_set << cp unless include?(cp)
        end
        new_set
      end

      def ranges
        RangeCompressor.compress(self)
      end

      def sample(count = nil)
        count.nil? ? to_a(true).sample : to_a(true).sample(count)
      end

      def used_by?(string)
        string.each_codepoint { |cp| return true if include?(cp) }
        false
      end

      def cover?(string)
        string.each_codepoint { |cp| return false unless include?(cp) }
        true
      end
    end
  end
end
