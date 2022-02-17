require_relative './shared'

str = 'Lorem ipsum et dolorem'
rx = /\S/
cs = CharacterSet.whitespace.inversion

benchmark(
  caption: 'Detecting non-whitespace',
  cases: {
    'Regexp#match?'       => -> { rx.match?(str) },
    'CharacterSet#cover?' => -> { cs.cover?(str) },
  }
)

str = 'Lorem ipsum et dolorem'
rx = /[^a-z]/i
cs = CharacterSet.new('A'..'Z') + CharacterSet.new('a'..'z')

benchmark(
  caption: 'Detecting non-letters',
  cases: {
    'Regexp#match?'       => -> { rx.match?(str) },
    'CharacterSet#cover?' => -> { cs.cover?(str) },
  }
)
