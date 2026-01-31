## 2.0.0

Features:

  - [Add callstack tracking for null objects](https://github.com/avdi/naught/commit/5660cd3b9ae3ebfc1af40cb9c8f797635727e585) - New `config.callstack` option records all method calls made on a null object, including arguments and source location. Use `__call_trace__` to inspect the recorded calls.
  - [Add null-safe proxy for chained method calls](https://github.com/avdi/naught/commit/51b5ae4040b0128e62159166bc40d476d876a6c2) - New `config.null_safe_proxy` enables the `NullSafe()` conversion function that wraps values in a proxy, replacing nil returns with null objects for safe method chaining.

Bug fixes:

  - [Fix Marshal.dump compatibility with black_hole null objects](https://github.com/avdi/naught/commit/bd9b135c59a428aa63338851d5f8e378ebc92e1f)
  - [Fix composing mimic with predicates_return for classes with method_missing](https://github.com/avdi/naught/commit/37991c216a605600452d52c76380cfc11d18ca4b)

## 1.1.0

  - [Make it possible to supply an example object to mimic, with no class.](https://github.com/avdi/naught/commit/df2b62c027812760ce200177ce056929b5aea339)
  - [Define implicit conversion for to_hash](https://github.com/avdi/naught/commit/e20dc472d3bc71ba927d6ddb0fb0032e1646df77)
  - [Define implicit conversion for to_int](https://github.com/avdi/naught/commit/d32d4ea32a9a847bffd6cf18f480bdfaaf7a3641)

## 1.0.0

  - [Replace `::BasicObject` with `Naught::BasicObject`](https://github.com/avdi/naught/commit/8defad0bf9eb65e33054bf0a6e9c625c87c3e6df)
  - [Delegate explicit conversions to nil instead of defining them explicitly](https://github.com/avdi/naught/commit/85c195de80ed56993b88f47e09112c903a92a167)
  - Add support for (and run tests on) Ruby 1.8, 1.9, 2.0, 2.1, JRuby, and Rubinius

## 0.0.3

Features:

  - New "pebble" mode (Guilherme Carvalho)

