# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## UNRELEASED

### Added
- improved `String` manipulation speed
- `#count_in` and `#scan_in` methods for `String` interaction
- new predefined sets `CharacterSet::any`, `::assigned`, `::surrogate`
- conversion methods `#assigned_part`, `#valid_part`
- section methods `#plane(n)`, `#ascii_part`, `#ascii_part?`, `#ascii_only?`, `#ascii_ratio`, `#astral_only?`

### Fixed
- reduced memory consumption by > 90% for most use cases by dynamic resizing
  - before, every set instance needed 136 KB
  - now 16 bytes for a CharacterSet in ASCII space, 8 KB for one in BMP space etc.
- `CharacterSet::Pure#keep_in`, `#delete_in` now preserve the original encoding
- `#count` now supports passing an argument or block

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
