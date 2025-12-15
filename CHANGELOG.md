# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-15

### Added
- Initial release
- Complete FSRS v6.0 algorithm implementation
- Exponential difficulty formula
- Linear damping for difficulty changes
- Short-term learning with minute-based scheduling
- 21 parameter support (w[0] through w[20])
- Parameter migration from v4/v5 to v6
- Alea seeded PRNG for fuzzing
- Strategy pattern for schedulers, learning steps, and seed generation
- Cross-validation with TypeScript implementation
- Comprehensive test suite with RSpec
