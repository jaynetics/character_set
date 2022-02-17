require_relative './shared'

cs1 = CharacterSet.new(0...0x88000)
cs2 = CharacterSet.new(0x88000..0x10FFFF)

ss1 = SortedSet.new(0...0x88000)
ss2 = SortedSet.new(0x88000..0x10FFFF)

benchmark(
  caption: 'Merging entries',
  cases: {
    'CharacterSet#merge' => -> { cs1.merge(cs2) },
    'SortedSet#merge'    => -> { ss1.merge(ss2) },
  }
)
