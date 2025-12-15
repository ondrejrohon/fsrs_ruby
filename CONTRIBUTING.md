# Contributing to FSRS Ruby

Thank you for your interest in contributing! 🎉

## Development Setup

```bash
git clone https://github.com/ondrejrohon/fsrs_ruby.git
cd fsrs_ruby
bundle install
```

## Running Tests

```bash
# Run all tests
bundle exec rspec

# Run with documentation format
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/fsrs_ruby/algorithm_spec.rb

# View coverage report
open coverage/index.html
```

## Making Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`bundle exec rspec`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to your branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## Code Style

This project aims to follow Ruby community standards. Before submitting:

- Ensure tests pass
- Maintain or improve test coverage
- Write clear commit messages
- Update documentation if needed

## Reporting Bugs

Found a bug? Please open an issue with:

- Ruby version
- Gem version
- Steps to reproduce
- Expected vs actual behavior
- Code sample (if applicable)

## Feature Requests

Have an idea? Open an issue describing:

- The problem you're trying to solve
- Your proposed solution
- Any alternatives you've considered

## Questions?

- Open a discussion on GitHub
- Check existing issues and documentation
- Contact: ondrej.rohon@gmail.com

Thank you for contributing! 🙏
