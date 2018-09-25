# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

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
