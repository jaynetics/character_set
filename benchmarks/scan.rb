require_relative './shared'

str = 'Lorem ipsum ⛷ et dolorem'
rx = /\p{emoji}/
cs = CharacterSet.emoji

benchmark(
  caption: 'Extracting emoji to an Array',
  cases: {
    'String#scan'       => -> { str.scan(rx) },
    'CharacterSet#scan' => -> { cs.scan(str) },
  }
)
