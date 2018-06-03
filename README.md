# CharacterSet

[![Gem Version](https://badge.fury.io/rb/character_set.svg)](http://badge.fury.io/rb/character_set)
[![Build Status](https://travis-ci.org/janosch-x/character_set.svg?branch=master)](https://travis-ci.org/janosch-x/character_set)

A gem to build, read, write, check and manipulate sorted sets of Unicode codepoints.

## Usage

### Read/Initialize

These are all equivalent:

```ruby
CharacterSet.read('[a-c]')
CharacterSet.read('\x61-\u0063')
CharacterSet['a', 'b', 'c']
CharacterSet[97, 98, 99]
CharacterSet.new([0x61, 0x62, 0x63])
```

### Write
```ruby
set = CharacterSet['a', 'b', 'c', 'x']

# printable ASCII chars are not escaped by default
set.to_s # => 'a-cx'
set.to_s(escape_all: true) # => '\x61-\x63\x78'

# brackets are optional
set.to_s(in_brackets: true) # => '[a-cx]'

# the default escape format is Ruby/ES6 compatible, others are available
set = CharacterSet['a', 'b', 'c', 'ɘ', '🤩']
set.to_s # => 'a-c\u0258\u{1F929}'
set.to_s(format: 'U+') # => 'a-cU+0258U+1F929'
set.to_s(format: 'Python') # => "a-c\u0258\U0001F929"
set.to_s(format: 'raw') # => 'a-cɘ🤩'

# for full js compatibility in case of astral members:
set.to_s_with_surrogate_pair_alternation # => '(?:[\u0258]|\ud83e\udd29)'
```

### Manipulate

Use [any Ruby Set method](https://ruby-doc.org/stdlib-2.5.1/libdoc/set/rdoc/Set.html) to intersect, unite, add, delete, check for presence of elements or overlaps between sets etc.

Where appropriate, methods take both chars and codepoints, e.g.:

```ruby
CharacterSet['a'].include?('a') # true
CharacterSet['a'].include?(0x61) # true
```

`#invert` can be used to create a `CharacterSet` covering all valid Unicode codepoints that are not in the current set:

```ruby
set = CharacterSet['a'].invert(upto: 0x10FFFF, ucp_only: true)
set.size # => 1112063
set.include?('a') # => false
```

There are also some methods to handle [BMP](https://en.wikipedia.org/wiki/Plane_%28Unicode%29#Basic_Multilingual_Plane) and astral parts:
```Ruby
CharacterSet.read('aɘ🤩').bmp_part == CharacterSet['a', 'ɘ']
CharacterSet.read('aɘ🤩').astral_part == CharacterSet['🤩']
CharacterSet.read('aɘ🤩').bmp_ratio # => 0.6666666
CharacterSet.read('aɘ🤩').member_in_plane?(0) # => true
CharacterSet::Character.new(0x61).plane # => 0
```

Many parts are reusable, e.g. `CharacterSet::Character`, `CharacterSet::RangeCompressor`, `CharacterSet::Reader`, `CharacterSet::Writer`.

### Common utility sets

```ruby
CharacterSet.ascii
CharacterSet.newlines
CharacterSet.unicode
```
