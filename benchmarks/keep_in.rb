require_relative './shared'

str = 'Lorem ipsum et dolorem'
rx = /\S/
cs = CharacterSet.whitespace

benchmark(
  caption: 'Removing non-whitespace',
  cases: {
    'String#gsub'          => -> { str.gsub(rx, '') },
    'CharacterSet#keep_in' => -> { cs.keep_in(str) },
  }
)

str = 'Lorem ipsum ⛷ et dolorem'
rx = /\p{^emoji}/
cs = CharacterSet.emoji

benchmark(
  caption: 'Extracting emoji',
  cases: {
    'String#gsub'          => -> { str.gsub(rx, '') },
    'CharacterSet#keep_in' => -> { cs.keep_in(str) },
  }
)
