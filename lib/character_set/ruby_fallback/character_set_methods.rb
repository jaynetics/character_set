class CharacterSet
  module RubyFallback
    module CharacterSetMethods
      module ClassMethods
        def from_ranges(*ranges)
          new(Array(ranges).flat_map(&:to_a))
        end

        def of_string(str)
          raise ArgumentError, 'pass a String' unless str.respond_to?(:codepoints)
          str.encode('utf-8').each_codepoint.with_object(new) { |cp, set| set << cp }
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
        CharacterSet.require_optional_dependency('range_compressor', __method__)
        RangeCompressor.compress(self)
      end

      def sample(count = nil)
        count.nil? ? to_a(true).sample : to_a(true).sample(count)
      end

      def count_in(string)
        utf8_str!(string).each_codepoint.count { |cp| include?(cp) }
      end

      def cover?(string)
        utf8_str!(string).each_codepoint { |cp| return false unless include?(cp) }
        true
      end

      def delete_in(string)
        utf8_str!(string).each_codepoint.with_object('') do |cp, new_str|
          include?(cp) || (new_str << cp)
        end.encode(string.encoding)
      end

      def delete_in!(string)
        result = delete_in(string)
        result.size == string.size ? nil : string.replace(result)
      end

      def keep_in(string)
        utf8_str!(string).each_codepoint.with_object('') do |cp, new_str|
          include?(cp) && (new_str << cp)
        end.encode(string.encoding)
      end

      def keep_in!(string)
        result = keep_in(string)
        result.size == string.size ? nil : string.replace(result)
      end

      def scan(string)
        utf8_str!(string).each_codepoint.with_object([]) do |cp, arr|
          arr.push(cp.chr('utf-8')) if include?(cp)
        end
      end

      def used_by?(string)
        utf8_str!(string).each_codepoint { |cp| return true if include?(cp) }
        false
      end

      def section(from:, upto: 0x10FFFF)
        dup.keep_if { |cp| cp >= from && cp <= upto }
      end

      def count_in_section(from:, upto: 0x10FFFF)
        count { |cp| cp >= from && cp <= upto }
      end

      def section?(from:, upto: 0x10FFFF)
        any? { |cp| cp >= from && cp <= upto }
      end

      def section_ratio(from:, upto: 0x10FFFF)
        section(from: from, upto: upto).count / count.to_f
      end

      def planes
        plane_size = 0x10000.to_f
        inject({}) { |hash, cp| hash.merge((cp / plane_size).floor => 1) }.keys
      end

      def plane(num)
        validate_plane_number(num)
        section(from: (num * 0x10000), upto: ((num + 1) * 0x10000) - 1)
      end

      def member_in_plane?(num)
        validate_plane_number(num)
        ((num * 0x10000)...((num + 1) * 0x10000)).any? { |cp| include?(cp) }
      end

      private

      def validate_plane_number(num)
        num >= 0 && num <= 16 or raise ArgumentError, 'plane must be between 0 and 16'
      end

      def utf8_str!(obj)
        raise ArgumentError, 'pass a String' unless obj.respond_to?(:codepoints)
        obj.encode('utf-8')
      end
    end
  end
end
