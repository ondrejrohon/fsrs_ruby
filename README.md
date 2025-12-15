# FSRS Ruby - v6.0

A complete Ruby port of the [FSRS (Free Spaced Repetition Scheduler)](https://github.com/open-spaced-repetition/fsrs) algorithm version 6.0.

## Features

- ✅ **FSRS v6.0 Algorithm**: Exponential difficulty formula, linear damping, 21 parameters
- ✅ **Short-term Learning**: Minute-based scheduling with learning steps (e.g., `['1m', '10m']`)
- ✅ **State Machine**: NEW → LEARNING → REVIEW ↔ RELEARNING
- ✅ **Parameter Migration**: Automatic migration from v4/v5 to v6 format
- ✅ **Fuzzing**: Optional interval randomization using Alea PRNG
- ✅ **Strategy Pattern**: Pluggable schedulers, learning steps, and seed strategies
- ✅ **Cross-validated**: Outputs match TypeScript implementation to 8 decimal places

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fsrs_ruby'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install fsrs_ruby
```

## Usage

### Basic Example

```ruby
require 'fsrs_ruby'

# Create FSRS instance with default parameters
fsrs = FsrsRuby.new

# Create a new card
card = FsrsRuby.create_empty_card(Time.now)

# Preview all possible ratings (Again, Hard, Good, Easy)
preview = fsrs.repeat(card, Time.now)

# Access results for each rating
good_result = preview[FsrsRuby::Rating::GOOD]
puts "If rated GOOD:"
puts "  Next review: #{good_result.card.due}"
puts "  Difficulty: #{good_result.card.difficulty}"
puts "  Stability: #{good_result.card.stability}"

# Apply a specific rating
result = fsrs.next(card, Time.now, FsrsRuby::Rating::GOOD)
updated_card = result.card
```

### Custom Parameters

```ruby
fsrs = FsrsRuby.new(
  request_retention: 0.9,           # Target 90% retention
  maximum_interval: 36500,          # Max interval in days (~100 years)
  enable_short_term: true,          # Use minute-based learning steps
  learning_steps: ['1m', '10m'],    # Learning: 1 minute, then 10 minutes
  relearning_steps: ['10m'],        # Relearning: 10 minutes
  enable_fuzz: false                # Disable interval randomization
)
```

### Getting Retrievability

```ruby
# Get memory retention probability
retrievability = fsrs.get_retrievability(card, Time.now)
# => "95.23%"

# Get as decimal
retrievability = fsrs.get_retrievability(card, Time.now, format: false)
# => 0.9523
```

### Rollback and Forget

```ruby
# Rollback a review
previous_card = fsrs.rollback(updated_card, review_log)

# Reset card to NEW state
forgotten = fsrs.forget(card, Time.now, reset_count: true)
```

### Custom Strategies

```ruby
# Custom seed strategy
fsrs.use_strategy(:seed, ->(scheduler) {
  "#{scheduler.current.id}_#{scheduler.current.reps}"
})

# Custom learning steps strategy
fsrs.use_strategy(:learning_steps, ->(params, state, cur_step) {
  # Return custom step logic
  {}
})
```

## Algorithm Overview

### State Transitions

```
NEW → LEARNING → REVIEW ↔ RELEARNING
```

- **NEW**: Card never reviewed
- **LEARNING**: Initial learning phase with short intervals
- **REVIEW**: Long-term review phase
- **RELEARNING**: Re-learning after forgetting (lapse)

### Ratings

- **Again (1)**: Complete failure, restart learning
- **Hard (2)**: Difficult to recall
- **Good (3)**: Recalled correctly with effort
- **Easy (4)**: Recalled easily

### Key Formulas (v6.0)

**Initial Difficulty (Exponential)**:
```
D₀(G) = w[4] - exp((G-1) × w[5]) + 1
```

**Next Difficulty (with Linear Damping)**:
```
Δd = -w[6] × (G - 3)
D' = D + linear_damping(Δd, D)
linear_damping(Δd, D) = (Δd × (10 - D)) / 9
```

**Forgetting Curve**:
```
R(t,S) = (1 + FACTOR × t / S)^DECAY
where: decay = -w[20], factor = exp(ln(0.9)/decay) - 1
```

## Development

After checking out the repo, run:

```bash
$ bundle install
$ bundle exec rake spec
```

## Cross-Validation

This implementation has been cross-validated against the TypeScript FSRS v6 implementation. All core formulas match to 8 decimal places.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

Based on the FSRS algorithm by [Jarrett Ye](https://github.com/L-M-Sherlock) and the [open-spaced-repetition](https://github.com/open-spaced-repetition) community.
