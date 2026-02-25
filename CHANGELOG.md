# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
