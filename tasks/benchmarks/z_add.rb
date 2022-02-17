require_relative './shared'

cs = CharacterSet[]
ss = SortedSet[]

benchmark(
  caption: 'Adding entries',
  cases: {
    'CharacterSet#add' => -> { cs.add(rand(0x10FFFF)) },
    'SortedSet#add'    => -> { ss.add(rand(0x10FFFF)) },
  }
)
