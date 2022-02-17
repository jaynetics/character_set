require_relative './shared'

str = 'Lorem     ipsum       et      dolorem'
rx = /\s/
trt = "\t\n\v\f\r\s"
cs = CharacterSet.whitespace

benchmark(
  caption: 'Removing ASCII whitespace',
  cases: {
    'String#gsub'            => -> { str.gsub(rx, '') },
    'String#tr'              => -> { str.tr(trt, '') },
    'CharacterSet#delete_in' => -> { cs.delete_in(str) },
  }
)

str = 'Lörem ipsüm ⛷ et dölörem'
rx = /[\s\p{emoji}äüö]/
trt = "\t\n\v\f\r\s😀-🙏äüö"
cs = CharacterSet.whitespace + CharacterSet.emoji + CharacterSet['ä', 'ö', 'ü']

benchmark(
  caption: 'Removing whitespace, emoji and umlauts',
  cases: {
    'String#gsub'            => -> { str.gsub(rx, '') },
    'String#tr'              => -> { str.tr(trt, '') },
    'CharacterSet#delete_in' => -> { cs.delete_in(str) },
  }
)
