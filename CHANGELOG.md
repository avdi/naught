# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/2.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.3.0] - 2026-03-04

### Added

- RBS signatures for all NullClassBuilder DSL methods dispatched via `method_missing` (`define_explicit_conversions`, `define_implicit_conversions`, `predicates_return`, `mimic`, `impersonate`, `pebble`, `singleton`, `traceable`, `callstack`, `null_safe_proxy`).

## [2.2.0] - 2026-03-04

### Fixed

- Include RBS signature file in gem package.

## [2.1.0] - 2026-02-06

### Added

- Dynamic method discovery for `mimic example:` ([#78]). When using `mimic example:`, Naught now automatically discovers and stubs dynamically-defined methods (via `method_missing`/`respond_to_missing?`). This fixes compatibility with libraries like Stripe that define methods based on API response data. Can be disabled with `include_dynamic: false`.

## [2.0.0] - 2026-02-01

### Added

- Callstack tracking for null objects ([5660cd3]). New `config.callstack` option records all method calls made on a null object, including arguments and source location. Use `__call_trace__` to inspect the recorded calls.
- Null-safe proxy for chained method calls ([51b5ae4]). New `config.null_safe_proxy` enables the `NullSafe()` conversion function that wraps values in a proxy, replacing nil returns with null objects for safe method chaining.

### Fixed

- Marshal.dump compatibility with black_hole null objects ([bd9b135]).
- Composing mimic with predicates_return for classes with method_missing ([37991c2]).

## [1.1.0] - 2015-09-08

### Added

- Support for supplying an example object to mimic ([df2b62c]).
- Implicit conversion for to_hash ([e20dc47]).
- Implicit conversion for to_int ([d32d4ea]).

## [1.0.0] - 2014-01-26

### Changed

- Replace `::BasicObject` with `Naught::BasicObject` ([8defad0]).
- Delegate explicit conversions to nil instead of defining them explicitly ([85c195d]).
- Add support for (and run tests on) Ruby 1.8, 1.9, 2.0, 2.1, JRuby, and Rubinius.

## [0.0.3] - 2013-11-08

### Added

- New "pebble" mode (Guilherme Carvalho).

[Unreleased]: https://github.com/avdi/naught/compare/v2.3.0...HEAD
[2.3.0]: https://github.com/avdi/naught/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/avdi/naught/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/avdi/naught/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/avdi/naught/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/avdi/naught/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/avdi/naught/compare/v0.0.3...v1.0.0
[0.0.3]: https://github.com/avdi/naught/compare/v0.0.2...v0.0.3

[#78]: https://github.com/avdi/naught/issues/78

[37991c2]: https://github.com/avdi/naught/commit/37991c216a605600452d52c76380cfc11d18ca4b
[51b5ae4]: https://github.com/avdi/naught/commit/51b5ae4040b0128e62159166bc40d476d876a6c2
[5660cd3]: https://github.com/avdi/naught/commit/5660cd3b9ae3ebfc1af40cb9c8f797635727e585
[85c195d]: https://github.com/avdi/naught/commit/85c195de80ed56993b88f47e09112c903a92a167
[8defad0]: https://github.com/avdi/naught/commit/8defad0bf9eb65e33054bf0a6e9c625c87c3e6df
[bd9b135]: https://github.com/avdi/naught/commit/bd9b135c59a428aa63338851d5f8e378ebc92e1f
[d32d4ea]: https://github.com/avdi/naught/commit/d32d4ea32a9a847bffd6cf18f480bdfaaf7a3641
[df2b62c]: https://github.com/avdi/naught/commit/df2b62c027812760ce200177ce056929b5aea339
[e20dc47]: https://github.com/avdi/naught/commit/e20dc472d3bc71ba927d6ddb0fb0032e1646df77
