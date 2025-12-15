# Testing Guide - FSRS Ruby

Quick reference for running and understanding the test suite.

## Quick Start

```bash
# Run all tests with coverage
bundle exec rspec

# Run specific test file
bundle exec rspec spec/fsrs_ruby/integration_spec.rb

# Run with detailed output
bundle exec rspec --format documentation

# View coverage report
open coverage/index.html
```

## Test Suite Overview

**Total Tests**: 69 examples  
**Coverage**: 80.73%  
**Status**: ✅ All passing

### Test Files

| File | Tests | Focus |
|------|-------|-------|
| `algorithm_spec.rb` | 3 | Core FSRS v6 formulas |
| `integration_spec.rb` | 15 | Cross-validation vs TypeScript |
| `fsrs_instance_spec.rb` | 32 | Public API functionality |
| `parameters_spec.rb` | 11 | Configuration and migration |
| `models_spec.rb` | 7 | Data structures |
| `alea_spec.rb` | 9 | Random number generation |
| `helpers_spec.rb` | 6 | Utility functions |

## Coverage Breakdown

### ✅ Excellent Coverage (>90%)
- Core algorithm
- FSRS instance methods
- Parameters and constants

### ⚠️ Moderate Coverage (70-90%)
- Schedulers
- Learning strategies

### 📌 Needs Improvement (<70%)
- Type converter utilities
- Custom seed strategies
- Some helper methods

## Cross-Validation

Tests validate against `spec/fixtures/ts_outputs.json` containing:
- ✅ All rating outcomes (Again, Hard, Good, Easy)
- ✅ Review sequences
- ✅ Lapse/relearning scenarios
- ✅ Parameter migration (v4→v6, v5→v6)

**Precision**: Values match TypeScript to 8 decimal places

## Common Test Commands

```bash
# Run only integration tests
bundle exec rspec spec/fsrs_ruby/integration_spec.rb

# Run only algorithm tests
bundle exec rspec spec/fsrs_ruby/algorithm_spec.rb

# Run a specific test by line number
bundle exec rspec spec/fsrs_ruby/integration_spec.rb:15

# Run tests matching a pattern
bundle exec rspec --example "matches TypeScript"

# Run with seed for reproducibility
bundle exec rspec --seed 12345
```

## Writing New Tests

### Example: Testing a new feature

```ruby
RSpec.describe 'MyFeature' do
  let(:fsrs) { FsrsRuby.new }
  let(:card) { FsrsRuby.create_empty_card(Time.now) }
  
  it 'does something expected' do
    result = fsrs.next(card, Time.now, FsrsRuby::Rating::GOOD)
    
    expect(result.card.state).to eq(FsrsRuby::State::LEARNING)
  end
end
```

### Comparing with TypeScript outputs

```ruby
it 'matches TypeScript output' do
  fixtures = load_fixtures
  ts_value = fixtures['my_feature']['output']
  
  result = my_ruby_method
  
  # Use be_close_to_ts for floats (8 decimal precision)
  expect(result).to be_close_to_ts(ts_value)
end
```

## Coverage Goals

- **Current**: 80.73%
- **Target**: 90%+
- **Minimum**: 80% (enforced by CI)

### To Improve Coverage

1. Add tests for untested error paths
2. Test edge cases (extreme values, nil handling)
3. Cover type converter methods
4. Test custom strategy variations

## CI/CD Integration

```yaml
# .github/workflows/test.yml example
- name: Run tests
  run: bundle exec rspec
  
- name: Check coverage
  run: |
    if [ $(cat coverage/.last_run.json | jq '.result.line') -lt 80 ]; then
      echo "Coverage below 80%"
      exit 1
    fi
```

## Troubleshooting

### Tests fail randomly
- Check for time-dependent tests
- Use fixed timestamps instead of `Time.now`
- Ensure PRNG seeds are set

### Coverage report not generated
- Ensure SimpleCov is loaded at top of `spec_helper.rb`
- Check that `coverage/` directory is writable

### Slow tests
- Current suite runs in ~0.01s
- If slower, check for:
  - Network calls (should be none)
  - Large loops
  - Unnecessary file I/O

## Additional Resources

- Full verification report: `VERIFICATION_REPORT.md`
- RSpec documentation: https://rspec.info/
- SimpleCov documentation: https://github.com/simplecov-ruby/simplecov

