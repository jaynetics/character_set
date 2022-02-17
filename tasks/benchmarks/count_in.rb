require_relative './shared'

str = 'Lorem ipsum et dolorem'
tr = '^A-Za-z'
cs = CharacterSet.non_ascii_letter

benchmark(
  caption: 'Counting non-letters',
  cases: {
    'String#count'          => -> { str.count(tr) },
    'CharacterSet#count_in' => -> { cs.count_in(str) },
  }
)
