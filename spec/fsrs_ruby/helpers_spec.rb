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
end

