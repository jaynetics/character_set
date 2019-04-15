require_relative './shared'

str = 'Lorem     ipsum       et      dolorem'
rx = /\s/
cs = CharacterSet.whitespace

benchmark(
  caption: 'Removing whitespace',
  cases: {
    'String#gsub'            => -> { str.gsub(rx, '') },
    'CharacterSet#delete_in' => -> { cs.delete_in(str) },
  }
)

str = 'Lörem ipsüm ⛷ et dölörem'
rx = /[\s\p{emoji}äüö]/
cs = CharacterSet.whitespace + CharacterSet.emoji + CharacterSet['ä', 'ö', 'ü']

benchmark(
  caption: 'Removing whitespace, emoji and umlauts',
  cases: {
    'String#gsub'            => -> { str.gsub(rx, '') },
    'CharacterSet#delete_in' => -> { cs.delete_in(str) },
  }
)
