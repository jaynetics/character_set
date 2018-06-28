# CharacterSet

[![Gem Version](https://badge.fury.io/rb/character_set.svg)](http://badge.fury.io/rb/character_set)
[![Build Status](https://travis-ci.org/janosch-x/character_set.svg?branch=master)](https://travis-ci.org/janosch-x/character_set)

A gem to build, read, write and compare sets of Unicode codepoints.

Many parts can be used independently, e.g. `CharacterSet::Character`, `CharacterSet::RangeCompressor`, `CharacterSet::Parser`, `CharacterSet::Writer`.

## Usage

### Parse/Initialize

These all produce a `CharacterSet` containing `a`, `b` and `c`:

```ruby
CharacterSet.parse('[a-c]')
CharacterSet.parse('\x61-\u0063')
CharacterSet['a', 'b', 'c']
CharacterSet[97, 98, 99]
CharacterSet.new('a'..'c')
CharacterSet.new(0x61..0x63)
CharacterSet.used_by('abacababa')
```

### Interact with Strings

`#used_by?` and `#cover?` are as fast as `Regexp#match?`.

```ruby
CharacterSet.ascii.used_by?('Tüür') # => true
CharacterSet.ascii.cover?('Tüür') # => false
CharacterSet.ascii.cover?('Tr') # => true
```

There is also a core extension for this.
```ruby
require 'character_set/core_ext'

"a\rb".character_set & CharacterSet.newline # => CharacterSet["\r"]
"a\rb".uses?(CharacterSet.newline) # => true
"a\rb".covered_by?(CharacterSet.newline) # => false
```

### Manipulate

Use any [Ruby Set method](https://ruby-doc.org/stdlib-2.5.1/libdoc/set/rdoc/Set.html) to perform modifications, checks and comparisons between character sets.

Where appropriate, methods take both chars and codepoints, e.g.:

```ruby
CharacterSet['a'].add('b') # => CharacterSet['a', 'b']
CharacterSet['a'].add(98) # => CharacterSet['a', 'b']
CharacterSet['a'].include?('b') # => false
CharacterSet['a'].include?(0x62) # => false
```

`#inversion` can be used to create a `CharacterSet` with all valid Unicode codepoints that are not in the current set:

```ruby
non_a = CharacterSet['a'].inversion
# => #<CharacterSet (size: 1112063)>

non_a.include?('a') # => false
non_a.include?('ü') # => true

# to include surrogate pair halves:
CharacterSet['a'].inversion(include_surrogates: true)
# => #<CharacterSet (size: 1114111)>
```

### Write
```ruby
set = CharacterSet['a', 'b', 'c', 'j', '-']

# safely printable ASCII chars are not escaped by default
set.to_s # => 'a-cj\x2D'
set.to_s(escape_all: true) # => '\x61-\x63\x6A\x2D'

# brackets may be added
set.to_s(in_brackets: true) # => '[a-cj\x2D]'

# the default escape format is Ruby/ES6 compatible, others are available
set = CharacterSet['a', 'b', 'c', 'ɘ', '🤩']
set.to_s # => 'a-c\u0258\u{1F929}'
set.to_s(format: 'U+') # => 'a-cU+0258U+1F929'
set.to_s(format: 'Python') # => "a-c\u0258\U0001F929"
set.to_s(format: 'raw') # => 'a-cɘ🤩'

# or pass a block
set.to_s { |char| "[#{char.codepoint}]" } # => "a-c[600][129321]"
set.to_s(escape_all: true) { |c| "<#{c.hex}>" } # => "<61>-<63><258><1F929>"

# disable abbreviation (grouping of codepoints in ranges)
set.to_s(abbreviate: false) # => "abc\u0258\u{1F929}"

# for full js regex compatibility in case of astral members:
set.to_s_with_surrogate_pair_alternation # => '(?:[\u0258]|\ud83e\udd29)'
```

### Common utility sets

```ruby
CharacterSet.ascii
CharacterSet.emoji
CharacterSet.newline
CharacterSet.unicode

CharacterSet.emoji.sample(5) # => ["⛷", "👈", "🌞", "♑", "⛈"]
```

### Unicode plane methods

There are some methods to check for planes and to handle [BMP](https://en.wikipedia.org/wiki/Plane_%28Unicode%29#Basic_Multilingual_Plane) and astral parts:
```Ruby
CharacterSet['a', 'ü', '🤩'].bmp_part # => CharacterSet['a', 'ü']
CharacterSet['a', 'ü', '🤩'].astral_part # => CharacterSet['🤩']
CharacterSet['a', 'ü', '🤩'].bmp_ratio # => 0.6666666
CharacterSet['a', 'ü', '🤩'].planes # => [0, 1]
CharacterSet['a', 'ü', '🤩'].member_in_plane?(7) # => false
CharacterSet::Character.new(0x61).plane # => 0
```
