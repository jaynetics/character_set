require 'set'
require 'sorted_integer_set_ext'

require_relative 'character_set/character'
require_relative 'character_set/common_sets'
require_relative 'character_set/plane_methods'
require_relative 'character_set/range_compressor'
require_relative 'character_set/reader'
require_relative 'character_set/set_methods'
require_relative 'character_set/version'
require_relative 'character_set/writer'

class CharacterSet < SortedSet
  extend CommonSets
  include PlaneMethods
  include SetMethods
  include SortedIntegerSetExt

  def initialize(enumerable = [])
    super(Reader.codepoints_from_enumerable(enumerable))
  end

  def self.read(string)
    codepoints = Reader.codepoints_from_bracket_expression(string)
    set = new(codepoints)
    string.start_with?('[^') ? set.invert(upto: 0x10FFFF, ucp_only: true) : set
  end

  def to_s(opts = {})
    Writer.write(ranges, opts)
  end

  def to_s_with_surrogate_pair_alternation
    Writer.write_surrogate_pair_alternation(bmp_part.ranges, astral_part.ranges)
  end

  def ranges
    RangeCompressor.compress(self)
  end

  def inspect
    "#<CharacterSet (size: #{size})>"
  end
end
