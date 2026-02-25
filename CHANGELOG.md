# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Fixes an issue where scrolling to find an element on screen didn't work correctly
  because the scroll origin kept shifting with each attempt.
  Now scrolling reliably starts from the center of the screen every time.
- Fixes running the unit tests on macOS.
- Fixes text extraction to correctly capture multiple variable values from a single label.
- When staying on the same screen while it changes,
  the code generation now produces unique page names
  (e.g. Settings, Settings2, Settings3)
  instead of reusing the same name each time.

## [0.1.0] - 2025-11-19

### Added

- Declarative page-based UI testing built on top of XCTest.
- Automatic code generation for page descriptions via `startCodeGeneration()`.
- `SecureTextField` element with value checking support.
- System alert interruption handling.
- User-defined UI interruption handling.
- Conditionals and optionals in page declarations.
- Element visibility check function.
- Tap with offset support.
- Screenshots when checking for pages.
- Toggle component support (mapped to Switch in UITests).
- `StaticText` matching with identifier only.
- `Other` page elements functionality.
- Application property in code generation.
- Child elements for non-standard element types.
- Extensive test suite.

### Changed

- Element matching takes the view hierarchy into consideration.
- Page `application` property changed to `String`.
- More reliable code generation with less noise in generated code.
- More stable typing in web views.
- More stable test execution with fresh simulators.
- More helpful error messages and better predicate output in element queries.
- Actual page snapshot is provided when waiting for a page fails.
- Reorganized code structure.

### Fixed

- Secure text field mixup.
- Correct querying of `StaticText` that uses an identifier.
- Keyboard dismissal.

[Unreleased]: https://github.com/SisyphosTests/Sisyphos/compare/0.1.0...HEAD
[0.1.0]: https://github.com/SisyphosTests/Sisyphos/releases/tag/0.1.0
