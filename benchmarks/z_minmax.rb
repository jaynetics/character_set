require_relative './shared'

cs = CharacterSet.new(0..0xFFFF)
ss = SortedSet.new(0..0xFFFF)

benchmark(
  caption: 'Getting the min and max',
  cases: {
    'CharacterSet#minmax' => -> { cs.minmax },
    'SortedSet#minmax'    => -> { ss.minmax },
  }
)
