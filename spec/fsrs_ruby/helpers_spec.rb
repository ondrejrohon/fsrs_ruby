# frozen_string_literal: true

RSpec.describe 'FsrsRuby Helpers' do
  describe 'ParameterUtils' do
    describe '.create_empty_card' do
      it 'creates a card with NEW state' do
        card = FsrsRuby.create_empty_card
        
        expect(card).to be_a(FsrsRuby::Card)
        expect(card.state).to eq(FsrsRuby::State::NEW)
        expect(card.reps).to eq(0)
        expect(card.lapses).to eq(0)
      end

      it 'sets due time to provided time' do
        now = Time.parse('2024-01-15T12:00:00Z')
        card = FsrsRuby.create_empty_card(now)
        
        expect(card.due).to eq(now)
      end

      it 'sets due time to current time if not provided' do
        before_time = Time.now
        card = FsrsRuby.create_empty_card
        after_time = Time.now
        
        expect(card.due).to be_between(before_time, after_time)
      end
    end
  end

  describe 'DateTimeUtils' do
    it 'has date_diff method for calculating day differences' do
      # This is tested implicitly through card scheduling
      fsrs = FsrsRuby.new
      now = Time.parse('2024-01-01T00:00:00Z')
      card = FsrsRuby.create_empty_card(now)
      
      # Progress card
      result1 = fsrs.next(card, now, FsrsRuby::Rating::GOOD)
      result2 = fsrs.next(result1.card, result1.card.due, FsrsRuby::Rating::GOOD)
      
      # Review after scheduled days
      later = result2.card.due
      result3 = fsrs.next(result2.card, later, FsrsRuby::Rating::GOOD)
      
      expect(result3.card.elapsed_days).to be >= 0
    end

    it 'handles date_scheduler for minute-based scheduling' do
      fsrs = FsrsRuby.new(enable_short_term: true, learning_steps: ['1m', '10m'])
      now = Time.parse('2024-01-01T00:00:00Z')
      card = FsrsRuby.create_empty_card(now)
      
      result = fsrs.next(card, now, FsrsRuby::Rating::GOOD)
      
      # Should schedule in minutes
      time_diff = result.card.due - now
      expect(time_diff).to be > 0
      expect(time_diff).to be < 3600 # Less than 1 hour
    end
  end

  describe 'Time unit parsing' do
    it 'handles minute-based learning steps' do
      fsrs = FsrsRuby.new(
        enable_short_term: true,
        learning_steps: ['1m', '5m', '10m']
      )
      
      now = Time.parse('2024-01-01T00:00:00Z')
      card = FsrsRuby.create_empty_card(now)
      
      # First step should use first learning step
      result = fsrs.next(card, now, FsrsRuby::Rating::GOOD)
      expect(result.card.learning_steps).to eq(1)
    end

    it 'handles day-based intervals when short_term disabled' do
      fsrs = FsrsRuby.new(enable_short_term: false)
      
      now = Time.parse('2024-01-01T00:00:00Z')
      card = FsrsRuby.create_empty_card(now)
      
      result1 = fsrs.next(card, now, FsrsRuby::Rating::GOOD)
      result2 = fsrs.next(result1.card, result1.card.due, FsrsRuby::Rating::GOOD)
      
      # Should have days scheduled
      expect(result2.card.scheduled_days).to be > 0
    end
  end

  describe 'Helpers module' do
    describe '.round8' do
      it 'rounds to 8 decimal places' do
        result = FsrsRuby::Helpers.round8(1.123456789)
        expect(result).to eq(1.12345679)
      end

      it 'returns nil for nil input' do
        result = FsrsRuby::Helpers.round8(nil)
        expect(result).to be_nil
      end
    end

    describe '.clamp' do
      it 'clamps value to maximum' do
        result = FsrsRuby::Helpers.clamp(100, 0, 50)
        expect(result).to eq(50)
      end

      it 'clamps value to minimum' do
        result = FsrsRuby::Helpers.clamp(-10, 0, 50)
        expect(result).to eq(0)
      end

      it 'returns value if within range' do
        result = FsrsRuby::Helpers.clamp(25, 0, 50)
        expect(result).to eq(25)
      end
    end

    describe '.date_diff' do
      it 'calculates difference in days' do
        now = Time.parse('2024-01-10T00:00:00Z')
        pre = Time.parse('2024-01-05T00:00:00Z')
        
        result = FsrsRuby::Helpers.date_diff(now, pre, :days)
        expect(result).to eq(5)
      end

      it 'calculates difference in minutes' do
        now = Time.parse('2024-01-01T01:00:00Z')
        pre = Time.parse('2024-01-01T00:00:00Z')
        
        result = FsrsRuby::Helpers.date_diff(now, pre, :minutes)
        expect(result).to eq(60)
      end

      it 'raises error for invalid unit' do
        now = Time.now
        pre = Time.now - 3600
        
        expect {
          FsrsRuby::Helpers.date_diff(now, pre, :hours)
        }.to raise_error(ArgumentError, /Invalid unit/)
      end
    end

    describe '.get_fuzz_range' do
      it 'handles small intervals' do
        result = FsrsRuby::Helpers.get_fuzz_range(2.0, 0, 36500)
        expect(result[:min_ivl]).to eq(2)
        expect(result[:max_ivl]).to be >= result[:min_ivl]
      end

      it 'handles medium intervals (2.5-7)' do
        result = FsrsRuby::Helpers.get_fuzz_range(5.0, 0, 36500)
        expect(result[:min_ivl]).to be >= 2
        expect(result[:max_ivl]).to be > result[:min_ivl]
      end

      it 'handles intervals >= 7 and < 20' do
        result = FsrsRuby::Helpers.get_fuzz_range(10.0, 0, 36500)
        expect(result[:min_ivl]).to be >= 2
        expect(result[:max_ivl]).to be > result[:min_ivl]
      end

      it 'handles intervals >= 20' do
        result = FsrsRuby::Helpers.get_fuzz_range(30.0, 0, 36500)
        expect(result[:min_ivl]).to be >= 2
        expect(result[:max_ivl]).to be > result[:min_ivl]
      end

      it 'respects maximum interval' do
        result = FsrsRuby::Helpers.get_fuzz_range(100.0, 0, 50)
        expect(result[:max_ivl]).to eq(50)
      end

      it 'ensures min_ivl > elapsed_days when interval exceeds it' do
        result = FsrsRuby::Helpers.get_fuzz_range(10.0, 8, 36500)
        expect(result[:min_ivl]).to be > 8
      end

      it 'ensures min_ivl <= max_ivl' do
        result = FsrsRuby::Helpers.get_fuzz_range(50.0, 49, 51)
        expect(result[:min_ivl]).to be <= result[:max_ivl]
      end
    end

    describe '.format_date' do
      it 'formats time as YYYY-MM-DD HH:MM:SS' do
        time = Time.parse('2024-01-15T12:30:45Z')
        result = FsrsRuby::Helpers.format_date(time)
        expect(result).to match(/2024-01-15 \d{2}:\d{2}:\d{2}/)
      end
    end

    describe '.date_diff_in_days' do
      it 'calculates day difference ignoring time' do
        last = Time.parse('2024-01-01T23:59:59Z')
        cur = Time.parse('2024-01-05T00:00:01Z')
        
        result = FsrsRuby::Helpers.date_diff_in_days(last, cur)
        expect(result).to eq(4)
      end
    end
  end
end

