# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.8.0] - 2024-01-07

### Added

- support for `#<=>` and `#join`, which were added to `set` in the meantime
- support for getting the (overall) character set of a Regexp with multiple expressions
- support for global and local case-insensitivity in Regexp inputs
- `Regexp#{covered_by_character_set?,uses_character_set?}` methods (if core ext is used)

## [1.7.0] - 2023-05-12

### Added

- new codepoints for `::assigned` and `::emoji` predefined sets, as in Ruby 3.2.0

### Fixed

- fixed processing of Strings that are not ASCII- or UTF8-encoded
- removed dependency on `set` and `sorted_set`
  - thanks to https://github.com/mikebaldry for reporting a related issue (#2)

## [1.6.0] - 2022-02-16

### Added

- `::of` now supports both `String` and `Regexp` arguments

### Fixed

- fixed segfault during `String` manipulation on Ruby 3.2.0-dev
- improved performance for `String` manipulation
- allow usage in Ractors
  - predefined sets must be pre-initialized for this, though
  - e.g. `CharacterSet.ascii`, `keep_character_set(:ascii)` etc.
  - call them once in the main Ractor to trigger initialization

## [1.5.0] - 2021-12-05

### Added

- new codepoints for `::assigned` and `::emoji` predefined sets, as in Ruby 3.1.0
- latest unicode case-folding data (for `#case_insensitive`)
- support for passing any Enumerable to `#disjoint?`, `#intersect?`
  - this matches recent broadening of these methods in `ruby/set`
- new instance method `#secure_token` (see README)
- class method `::of` now accepts more than one `String`
- `CharacterSet::ExpressionConverter` can now build output of any Set-like class

### Fixed

- `CharacterSet::Pure::of_expression` now returns a `CharacterSet::Pure`
  - it used to return a regular `CharacterSet`

## [1.4.1] - 2020-01-10

### Fixed
- multiple fixes for Ruby 3
  - fixed segfault for some `String` manipulation cases
  - added `sorted_set` as dependency, so `CharacterSet::Pure` (non-C fallback) works
- fixed error when parsing a `Regexp` with an empty intersection (e.g. `/[a&&]/`)

## [1.4.0] - 2019-06-07

### Added
- `#to_s_with_surrogate_ranges` / `Writer::write_surrogate_ranges`
  - allows for much shorter astral plane representations e.g. in JavaScript
  - thanks to https://github.com/singpolyma for the suggestion and groundwork (#1)
- improved performance for `#to_s` / `Writer` by avoiding bugged `Range#minmax`

### Fixed
- '/' is now escaped by default when stringifying so as to work with //-regexp syntax

## [1.3.0] - 2019-04-26

### Added
- improved `String` manipulation speed
- improved initialization and `#merge` speed when passing a large `Range`
- reduced memory consumption by > 90% for most use cases via dynamic resizing
  - before, every set instance required 136 KB for codepoints
  - now, 16 bytes for a CharacterSet in ASCII space, 8 KB for one in BMP space etc.
- `#count_in` and `#scan` methods for `String` interaction
- new predefined sets `::any`/`::all`, `::assigned`, `::surrogate`
- conversion methods `#assigned_part`, `#valid_part`
- sectioning methods `#ascii_part`, `#plane(n)`
- section test methods `#ascii_part?`, `#ascii_ratio`, `#ascii_only?`, `#astral_only?`

### Fixed
- `#count` now supports passing an argument or block as usual
- `CharacterSet::Pure#keep_in`, `#delete_in` now preserve the original encoding

## [1.2.0] - 2019-04-02

### Added
- added latest Unicode casefold data (for `#case_insensitive`)

## [1.1.2] - 2018-09-25

### Fixed
- restored `range_compressor` as a runtime dependency for JRuby only

## [1.1.1] - 2018-09-24

### Fixed
- improved messages for missing optional dependencies
- made `range_compressor` an optional dependency as it is almost never needed

## [1.1.0] - 2018-09-21

### Added
- added option to reference a predefined set via Symbol in `String` extension methods
- added predefined sets `::ascii_alnum` and `::ascii_letters`

## [1.0.0] - 2018-09-02
Initial release.
