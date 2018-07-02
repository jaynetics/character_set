require_relative './shared'

str = 'Lorem ipsum et dolorem'
rx = /\s/
cs = CharacterSet.whitespace

benchmark(
  caption: 'Detecting whitespace',
  cases: {
    'Regexp#match?'         => -> { rx.match?(str) },
    'CharacterSet#used_by?' => -> { cs.used_by?(str) },
  }
)

str = 'Lorem ipsum et dolorem' * 20 + '⛷' + 'Lorem ipsum et dolorem' * 20
rx = /\p{emoji}/
cs = CharacterSet.emoji

benchmark(
  caption: 'Detecting emoji in a large string',
  cases: {
    'Regexp#match?'         => -> { rx.match?(str) },
    'CharacterSet#used_by?' => -> { cs.used_by?(str) },
  }
)
