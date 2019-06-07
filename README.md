# CharacterSet

[![Gem Version](https://badge.fury.io/rb/character_set.svg)](http://badge.fury.io/rb/character_set)
[![Build Status](https://travis-ci.org/jaynetics/character_set.svg?branch=master)](https://travis-ci.org/jaynetics/character_set)
[![codecov](https://codecov.io/gh/jaynetics/character_set/branch/master/graph/badge.svg)](https://codecov.io/gh/jaynetics/character_set)

This is a C-extended Ruby gem to work with sets of Unicode codepoints. It can read and write these sets in various formats and implements the stdlib `Set` interface for them.

It also offers an alternate paradigm of `String` processing which grants much better performance than `Regexp` and `String` methods from the stdlib where applicable (see [benchmarks](./BENCHMARK.md)).

Many parts can be used independently, e.g.:
- `CharacterSet::Character`
- `CharacterSet::Parser`
- `CharacterSet::Writer`
- [`RangeCompressor`](https://github.com/jaynetics/range_compressor)

## Usage

### Usage examples

```ruby
CharacterSet.url_query.cover?('?a=(b$c;)') # => true

CharacterSet.non_ascii.delete_in!(string)

CharacterSet.emoji.sample(5) # => ["⛷", "👈", "🌞", "♑", "⛈"]
```

### Parse/Initialize

These all produce a `CharacterSet` containing `a`, `b` and `c`:

```ruby
CharacterSet['a', 'b', 'c']
CharacterSet[97, 98, 99]
CharacterSet.new('a'..'c')
CharacterSet.new(0x61..0x63)
CharacterSet.of('abacababa')
CharacterSet.parse('[a-c]')
CharacterSet.parse('\U00000061-\U00000063')
```

If the gems [`regexp_parser`](https://github.com/ammar/regexp_parser) and [`regexp_property_values`](https://github.com/jaynetics/regexp_property_values) are installed, `::of_regexp` and `::of_property` can also be used. `::of_regexp` can handle intersections, negations, and set nesting. Regexp's `i`-flag is ignored; call `#case_insensitive` on the result if needed.

```ruby
CharacterSet.of_property('Thai') # => #<CharacterSet (size: 86)>

require 'character_set/core_ext/regexp_ext'

/[\D&&[:ascii:]&&\p{emoji}]/.character_set.size # => 2
```

### Predefined utility sets

`ascii`, `ascii_alnum`, `ascii_letter`, `assigned`, `bmp`, `crypt`, `emoji`, `newline`, `surrogate`, `unicode`, `url_fragment`, `url_host`, `url_path`, `url_query`, `whitespace`

```ruby
CharacterSet.ascii # => #<CharacterSet (size: 128)>

# all can be prefixed with `non_`, e.g.
CharacterSet.non_ascii
```

### Interact with Strings

`CharacterSet` can replace some types of `String` handling with better performance than the stdlib.

`#used_by?` and `#cover?` can replace some `Regexp#match?` calls:

```ruby
CharacterSet.ascii.used_by?('Tüür') # => true
CharacterSet.ascii.cover?('Tüür') # => false
CharacterSet.ascii.cover?('Tr') # => true
```

`#delete_in(!)` and `#keep_in(!)` can replace `String#gsub(!)` and the like:

```ruby
string = 'Tüür'

CharacterSet.ascii.delete_in(string) # => 'üü'
CharacterSet.ascii.keep_in(string) # => 'Tr'
string # => 'Tüür'

CharacterSet.ascii.delete_in!(string) # => 'üü'
string # => 'üü'
CharacterSet.ascii.keep_in!(string) # => ''
string # => ''
```

`#count_in` and `#scan` can replace `String#count` and `String#scan`:

```ruby
CharacterSet.non_ascii.count_in('Tüür') # => 2
CharacterSet.non_ascii.scan_in('Tüür') # => ['ü', 'ü']
```

There is also a core extension for String interaction.
```ruby
require 'character_set/core_ext/string_ext'

"a\rb".character_set & CharacterSet.newline # => CharacterSet["\r"]
"a\rb".uses_character_set?(CharacterSet['ä', 'ö', 'ü']) # => false
"a\rb".covered_by_character_set?(CharacterSet.newline) # => false

# predefined sets can also be referenced via Symbols
"a\rb".covered_by_character_set?(:ascii) # => true
"a\rb".delete_character_set(:newline) # => 'ab'
# etc.
```

### Manipulate

Use [any Ruby Set method](https://ruby-doc.org/stdlib-2.5.1/libdoc/set/rdoc/Set.html), e.g. `#+`, `#-`, `#&`, `#^`, `#intersect?`, `#<`, `#>` etc. to interact with other sets. Use `#add`, `#delete`, `#include?` etc. to change or check for members.

Where appropriate, methods take both chars and codepoints, e.g.:

```ruby
CharacterSet['a'].add('b') # => CharacterSet['a', 'b']
CharacterSet['a'].add(98) # => CharacterSet['a', 'b']
CharacterSet['a'].include?('a') # => true
CharacterSet['a'].include?(0x61) # => true
```

`#inversion` can be used to create a `CharacterSet` with all valid Unicode codepoints that are not in the current set:

```ruby
non_a = CharacterSet['a'].inversion
# => #<CharacterSet (size: 1112063)>

non_a.include?('a') # => false
non_a.include?('ü') # => true

# surrogate pair halves are not included by default
CharacterSet['a'].inversion(include_surrogates: true)
# => #<CharacterSet (size: 1114112)>
```

`#case_insensitive` can be used to create a `CharacterSet` where upper/lower case codepoints are supplemented:

```ruby
CharacterSet['1', 'A'].case_insensitive # => CharacterSet['1', 'A', 'a']
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

# astral members require some trickery if we want to target environments
# that are based on UTF-16 or "UCS-2 with surrogates", such as JavaScript.
set = CharacterSet['a', 'b', '🤩', '🤪', '🤫']

# Use #to_s_with_surrogate_ranges e.g. for JavaScript:
set.to_s_with_surrogate_ranges
# => '(?:[ab]|\uD83E[\uDD29-\uDD2B])'

# Or use #to_s_with_surrogate_alternation if such surrogate set pairs
# don't work in your target environment:
set.to_s_with_surrogate_alternation
# => '(?:[ab]|\uD83E\uDD29|\uD83E\uDD2A|\uD83E\uDD2B)'
```

### Unicode plane methods

There are some methods to check for planes and to handle ASCII, [BMP](https://en.wikipedia.org/wiki/Plane_%28Unicode%29#Basic_Multilingual_Plane) and astral parts:
```Ruby
CharacterSet['a', 'ü', '🤩'].ascii_part # => CharacterSet['a']
CharacterSet['a', 'ü', '🤩'].ascii_part? # => true
CharacterSet['a', 'ü', '🤩'].ascii_only? # => false
CharacterSet['a', 'ü', '🤩'].ascii_ratio # => 0.3333333
CharacterSet['a', 'ü', '🤩'].bmp_part # => CharacterSet['a', 'ü']
CharacterSet['a', 'ü', '🤩'].astral_part # => CharacterSet['🤩']
CharacterSet['a', 'ü', '🤩'].bmp_ratio # => 0.6666666
CharacterSet['a', 'ü', '🤩'].planes # => [0, 1]
CharacterSet['a', 'ü', '🤩'].plane(1) # => CharacterSet['🤩']
CharacterSet['a', 'ü', '🤩'].member_in_plane?(7) # => false
CharacterSet::Character.new('a').plane # => 0
```

### Contributions

Feel free to send suggestions, point out issues, or submit pull requests.
