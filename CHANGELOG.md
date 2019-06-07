# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

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
- `#count_in` and `#scan_in` methods for `String` interaction
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
