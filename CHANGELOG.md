# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.3.0] - 2026-03-04

### Added

- RBS signatures for all NullClassBuilder DSL methods dispatched via `method_missing` (`define_explicit_conversions`, `define_implicit_conversions`, `predicates_return`, `mimic`, `impersonate`, `pebble`, `singleton`, `traceable`, `callstack`, `null_safe_proxy`).

## [2.2.0] - 2026-03-04

### Fixed

- Include RBS signature file in gem package.

## [2.1.0] - 2025-02-06

### Added

- Dynamic method discovery for `mimic example:` ([#78](https://github.com/avdi/naught/issues/78)). When using `mimic example:`, Naught now automatically discovers and stubs dynamically-defined methods (via `method_missing`/`respond_to_missing?`). This fixes compatibility with libraries like Stripe that define methods based on API response data. Can be disabled with `include_dynamic: false`.

## [2.0.0] - 2025-02-01

### Added

- Callstack tracking for null objects ([5660cd3](https://github.com/avdi/naught/commit/5660cd3b9ae3ebfc1af40cb9c8f797635727e585)). New `config.callstack` option records all method calls made on a null object, including arguments and source location. Use `__call_trace__` to inspect the recorded calls.
- Null-safe proxy for chained method calls ([51b5ae4](https://github.com/avdi/naught/commit/51b5ae4040b0128e62159166bc40d476d876a6c2)). New `config.null_safe_proxy` enables the `NullSafe()` conversion function that wraps values in a proxy, replacing nil returns with null objects for safe method chaining.

### Fixed

- Marshal.dump compatibility with black_hole null objects ([bd9b135](https://github.com/avdi/naught/commit/bd9b135c59a428aa63338851d5f8e378ebc92e1f)).
- Composing mimic with predicates_return for classes with method_missing ([37991c2](https://github.com/avdi/naught/commit/37991c216a605600452d52c76380cfc11d18ca4b)).

## [1.1.0]

### Added

- Support for supplying an example object to mimic ([df2b62c](https://github.com/avdi/naught/commit/df2b62c027812760ce200177ce056929b5aea339)).
- Implicit conversion for to_hash ([e20dc47](https://github.com/avdi/naught/commit/e20dc472d3bc71ba927d6ddb0fb0032e1646df77)).
- Implicit conversion for to_int ([d32d4ea](https://github.com/avdi/naught/commit/d32d4ea32a9a847bffd6cf18f480bdfaaf7a3641)).

## [1.0.0]

### Changed

- Replace `::BasicObject` with `Naught::BasicObject` ([8defad0](https://github.com/avdi/naught/commit/8defad0bf9eb65e33054bf0a6e9c625c87c3e6df)).
- Delegate explicit conversions to nil instead of defining them explicitly ([85c195d](https://github.com/avdi/naught/commit/85c195de80ed56993b88f47e09112c903a92a167)).
- Add support for (and run tests on) Ruby 1.8, 1.9, 2.0, 2.1, JRuby, and Rubinius.

## [0.0.3]

### Added

- New "pebble" mode (Guilherme Carvalho).
