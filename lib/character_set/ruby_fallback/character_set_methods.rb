class CharacterSet
  module RubyFallback
    module CharacterSetMethods
      module ClassMethods
        def from_ranges(*ranges)
          new(Array(ranges).flat_map(&:to_a))
        end

        def of(string)
          raise ArgumentError, 'pass a String' unless string.is_a?(String)
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

      def case_insensitive
        new_set = dup
        each do |cp|
          swapped_cps = cp.chr('utf-8').swapcase.codepoints
          swapped_cps.size == 1 && new_set << swapped_cps[0]
        end
        new_set
      end

      def ranges
        CharacterSet.require_optional_dependency('range_compressor')
        RangeCompressor.compress(self)
      end

      def sample(count = nil)
        count.nil? ? to_a(true).sample : to_a(true).sample(count)
      end

      def used_by?(string)
        str!(string).each_codepoint { |cp| return true if include?(cp) }
        false
      end

      def cover?(string)
        str!(string).each_codepoint { |cp| return false unless include?(cp) }
        true
      end

      def delete_in(string)
        make_new_str(string) { |cp, new_str| include?(cp) || (new_str << cp) }
      end

      def delete_in!(string)
        result = delete_in(string)
        result.size == string.size ? nil : string.replace(result)
      end

      def keep_in(string)
        make_new_str(string) { |cp, new_str| include?(cp) && (new_str << cp) }
      end

      def keep_in!(string)
        result = keep_in(string)
        result.size == string.size ? nil : string.replace(result)
      end

      private

      def str!(obj)
        raise ArgumentError, 'pass a String' unless obj.respond_to?(:codepoints)
        obj
      end

      def make_new_str(original, &block)
        new_string = str!(original).each_codepoint.each_with_object('', &block)
        original.tainted? ? new_string.taint : new_string
      end
    end
  end
end
