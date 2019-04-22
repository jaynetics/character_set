require_relative './shared'

cs = CharacterSet[]
ss = SortedSet[]

benchmark(
  caption: 'Adding codepoints',
  cases: {
    'CharacterSet#add' => -> { cs.add(rand(0x10FFFF)) },
    'SortedSet#add'    => -> { ss.add(rand(0x10FFFF)) },
  }
)
