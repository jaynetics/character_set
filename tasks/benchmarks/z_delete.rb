require_relative './shared'

cs = CharacterSet.new(0..0x10FFFF)
ss = SortedSet.new(0..0x10FFFF)

benchmark(
  caption: 'Removing entries',
  cases: {
    'CharacterSet#delete' => -> { cs.delete(rand(0x10FFFF)) },
    'SortedSet#delete'    => -> { ss.delete(rand(0x10FFFF)) },
  }
)
