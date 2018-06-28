class CharacterSet
  module RangeCompressor
    module_function

    COMPRESSABLE_CLASSES = %w[
      CharacterSet
      CharacterSet::Pure
      ImmutableSet
      SortedSet
    ].freeze

    # Set#divide is extremely slow unfortunately, else it would be nice for this
    # divide { |i, j| (i - j).abs == 1 }
    def compress(enum)
      COMPRESSABLE_CLASSES.include?(enum.class.to_s) ||
        raise(ArgumentError, "pass a #{COMPRESSABLE_CLASSES.join('/')}")

      ranges = []
      previous_codepoint = nil
      current_start = nil
      current_end = nil

      enum.each do |codepoint|
        if previous_codepoint.nil?
          current_start = codepoint
        elsif previous_codepoint.next != codepoint
          # gap found, finalize previous range
          ranges << (current_start..current_end)
          current_start = codepoint
        end
        current_end = codepoint
        previous_codepoint = codepoint
      end

      # add final range
      ranges << (current_start..current_end) if current_start

      ranges
    end
  end
end
