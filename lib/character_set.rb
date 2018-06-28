require 'character_set/character'
require 'character_set/common_sets'
require 'character_set/parser'
require 'character_set/plane_methods'
require 'character_set/range_compressor'
require 'character_set/set_method_adapters'
require 'character_set/set_methods'
require 'character_set/version'
require 'character_set/writer'

class CharacterSet
  include Enumerable
  include PlaneMethods
  prepend SetMethodAdapters
  prepend SetMethods
  extend CommonSets

  begin
    require 'character_set/character_set'
  rescue LoadError
    require 'character_set/ruby_fallback'
    prepend RubyFallback
  end

  def initialize(enumerable = [])
    merge(Parser.codepoints_from_enumerable(enumerable))
  end

  def self.[](*args)
    new(Array(args))
  end

  def self.parse(string)
    codepoints = Parser.codepoints_from_bracket_expression(string)
    result = new(codepoints)
    string.start_with?('[^') ? result.inversion : result
  end

  def inversion(include_surrogates: false, upto: 0x10FFFF)
    ext_inversion(include_surrogates, upto)
  end

  def to_s(opts = {}, &block)
    Writer.write(ranges, opts, &block)
  end

  def to_s_with_surrogate_pair_alternation
    Writer.write_surrogate_pair_alternation(bmp_part.ranges, astral_part.ranges)
  end

  def inspect
    len = length
    "#<CharacterSet: {#{first(5) * ', '}#{'...' if len > 5}} (size: #{len})>"
  end
end
