# frozen_string_literal: false

require_relative 'shared'

cs1 = CharacterSet.new(0...0x88000)
cs2 = CharacterSet.new(0x88000..0x10FFFF)

ss1 = SortedSet.new(0...0x88000)
ss2 = SortedSet.new(0x88000..0x10FFFF)

benchmark(
  caption: 'Merging and resetting entries',
  cases: {
    'CharacterSet#merge/subtract' => -> { cs1.merge(cs2).subtract(cs2) },
    'SortedSet#merge/subtract' => -> { ss1.merge(ss2).subtract(ss2) }
  }
)
