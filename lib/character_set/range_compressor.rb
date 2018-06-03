class CharacterSet < SortedSet
  module RangeCompressor
    module_function

    # Set#divide is far too slow unfortunately
    # divide { |i, j| (i - j).abs == 1 }
    def compress(codepoint_set)
      codepoint_set.is_a?(SortedSet) || raise(ArgumentError, 'pass a SortedSet')

      hash = codepoint_set.instance_variable_get('@hash')

      hash.each_key.each_with_object([]) do |codepoint, arr|
        if codepoint.pred != @previous_codepoint
          @current_range = []
          arr << @current_range
        end
        @current_range << codepoint
        @previous_codepoint = codepoint
      end.map { |arr| arr[0]..arr[-1] }
    end
  end
end
