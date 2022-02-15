require_relative './shared'

str = 'Lorem ipsum et dolorem'
rx = /\S/
trt = "\u{0080}-\u{10FFFF}" # approximation
cs = CharacterSet.whitespace

benchmark(
  caption: 'Removing non-whitespace',
  cases: {
    'String#gsub'          => -> { str.gsub(rx, '') },
    'String#tr'            => -> { str.tr(trt, '') },
    'CharacterSet#keep_in' => -> { cs.keep_in(str) },
  }
)

str = 'Lorem ipsum ⛷ et dolorem'
rx = /\p{^emoji}/
trt = "\u0000-\u{1F599}\u{1F650}-\u{10FFFF}"
cs = CharacterSet.emoji

benchmark(
  caption: 'Keeping only emoji',
  cases: {
    'String#gsub'          => -> { str.gsub(rx, '') },
    'String#tr'            => -> { str.tr(trt, '') },
    'CharacterSet#keep_in' => -> { cs.keep_in(str) },
  }
)
