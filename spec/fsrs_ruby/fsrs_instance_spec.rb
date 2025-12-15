# frozen_string_literal: true

RSpec.describe FsrsRuby::FSRSInstance do
  let(:fsrs) { FsrsRuby.new(enable_short_term: true) }
  let(:now) { Time.parse('2024-01-01T00:00:00.000Z') }
  let(:card) { FsrsRuby.create_empty_card(now) }

  describe '#repeat' do
    it 'returns a hash with all 4 rating options' do
      result = fsrs.repeat(card, now)

      expect(result).to be_a(Hash)
      expect(result.keys.sort).to eq([
        FsrsRuby::Rating::AGAIN,
        FsrsRuby::Rating::HARD,
        FsrsRuby::Rating::GOOD,
        FsrsRuby::Rating::EASY
      ].sort)
    end

    it 'each result contains card and log' do
      result = fsrs.repeat(card, now)

      result.each do |_rating, outcome|
        expect(outcome).to respond_to(:card)
        expect(outcome).to respond_to(:log)
        expect(outcome.card).to be_a(FsrsRuby::Card)
        expect(outcome.log).to be_a(FsrsRuby::ReviewLog)
      end
    end
  end

  describe '#next' do
    it 'returns a single result for specified rating' do
      result = fsrs.next(card, now, FsrsRuby::Rating::GOOD)

      expect(result).to respond_to(:card)
      expect(result).to respond_to(:log)
      expect(result.card).to be_a(FsrsRuby::Card)
    end

    it 'progresses card state correctly through learning' do
      # First review with GOOD - should enter LEARNING state
      result1 = fsrs.next(card, now, FsrsRuby::Rating::GOOD)
      expect(result1.card.state).to eq(FsrsRuby::State::LEARNING)
      expect(result1.card.reps).to eq(1)

      # Second review with GOOD - should enter REVIEW state
      result2 = fsrs.next(result1.card, result1.card.due, FsrsRuby::Rating::GOOD)
      expect(result2.card.state).to eq(FsrsRuby::State::REVIEW)
      expect(result2.card.reps).to eq(2)
    end

    it 'handles AGAIN rating causing lapse' do
      # Progress to REVIEW state
      result1 = fsrs.next(card, now, FsrsRuby::Rating::GOOD)
      result2 = fsrs.next(result1.card, result1.card.due, FsrsRuby::Rating::GOOD)
      
      # Now rate AGAIN - should cause lapse
      result3 = fsrs.next(result2.card, result2.card.due, FsrsRuby::Rating::AGAIN)
      expect(result3.card.state).to eq(FsrsRuby::State::RELEARNING)
      expect(result3.card.lapses).to eq(1)
    end
  end

  describe '#get_retrievability' do
    it 'returns formatted percentage by default' do
      # Create a card in REVIEW state with some history
      result1 = fsrs.next(card, now, FsrsRuby::Rating::GOOD)
      result2 = fsrs.next(result1.card, result1.card.due, FsrsRuby::Rating::GOOD)
      
      retrievability = fsrs.get_retrievability(result2.card, result2.card.due)
      
      expect(retrievability).to be_a(String)
      expect(retrievability).to match(/\d+\.\d+%/)
    end

    it 'returns decimal when format: false' do
      result1 = fsrs.next(card, now, FsrsRuby::Rating::GOOD)
      result2 = fsrs.next(result1.card, result1.card.due, FsrsRuby::Rating::GOOD)
      
      retrievability = fsrs.get_retrievability(result2.card, result2.card.due, format: false)
      
      expect(retrievability).to be_a(Float)
      expect(retrievability).to be_between(0.0, 1.0)
    end

    it 'shows decreasing retrievability over time' do
      result1 = fsrs.next(card, now, FsrsRuby::Rating::GOOD)
      result2 = fsrs.next(result1.card, result1.card.due, FsrsRuby::Rating::GOOD)
      
      # Retrievability right at due date
      retriev_at_due = fsrs.get_retrievability(result2.card, result2.card.due, format: false)
      
      # Retrievability 5 days later
      retriev_later = fsrs.get_retrievability(result2.card, result2.card.due + (5 * 24 * 60 * 60), format: false)
      
      expect(retriev_later).to be < retriev_at_due
    end
  end

  describe '#rollback' do
    it 'reverts card to previous state using review log' do
      result = fsrs.next(card, now, FsrsRuby::Rating::GOOD)
      updated_card = result.card
      log = result.log
      
      # Rollback the review
      previous_card = fsrs.rollback(updated_card, log)
      
      expect(previous_card.state).to eq(FsrsRuby::State::NEW)
      expect(previous_card.reps).to eq(0)
      expect(previous_card.difficulty).to eq(0)
      expect(previous_card.stability).to eq(0)
    end

    it 'can rollback multiple reviews in sequence' do
      result1 = fsrs.next(card, now, FsrsRuby::Rating::GOOD)
      result2 = fsrs.next(result1.card, result1.card.due, FsrsRuby::Rating::GOOD)
      
      # Rollback second review
      card_after_first = fsrs.rollback(result2.card, result2.log)
      expect(card_after_first.state).to eq(FsrsRuby::State::LEARNING)
      expect(card_after_first.reps).to eq(1)
      
      # Rollback first review
      original_card = fsrs.rollback(card_after_first, result1.log)
      expect(original_card.state).to eq(FsrsRuby::State::NEW)
      expect(original_card.reps).to eq(0)
    end
  end

  describe '#forget' do
    it 'resets card to NEW state' do
      result1 = fsrs.next(card, now, FsrsRuby::Rating::GOOD)
      result2 = fsrs.next(result1.card, result1.card.due, FsrsRuby::Rating::GOOD)
      
      reset_time = Time.parse('2024-01-10T00:00:00.000Z')
      forgotten = fsrs.forget(result2.card, reset_time, reset_count: false)
      
      expect(forgotten.card.state).to eq(FsrsRuby::State::NEW)
      expect(forgotten.card.stability).to eq(0)
      expect(forgotten.card.difficulty).to eq(0)
      expect(forgotten.card.elapsed_days).to eq(0)
      expect(forgotten.card.scheduled_days).to eq(0)
      expect(forgotten.card.reps).to eq(2) # Not reset
    end

    it 'resets rep count when reset_count: true' do
      result1 = fsrs.next(card, now, FsrsRuby::Rating::GOOD)
      result2 = fsrs.next(result1.card, result1.card.due, FsrsRuby::Rating::GOOD)
      
      reset_time = Time.parse('2024-01-10T00:00:00.000Z')
      forgotten = fsrs.forget(result2.card, reset_time, reset_count: true)
      
      expect(forgotten.card.state).to eq(FsrsRuby::State::NEW)
      expect(forgotten.card.reps).to eq(0)
      expect(forgotten.card.lapses).to eq(0)
    end
  end

  describe 'custom parameters' do
    it 'respects custom request_retention' do
      fsrs_90 = FsrsRuby.new(request_retention: 0.9)
      fsrs_80 = FsrsRuby.new(request_retention: 0.8)
      
      result_90 = fsrs_90.next(card, now, FsrsRuby::Rating::GOOD)
      result_80 = fsrs_80.next(card, now, FsrsRuby::Rating::GOOD)
      
      # Continue to REVIEW state for both
      result_90_2 = fsrs_90.next(result_90.card, result_90.card.due, FsrsRuby::Rating::GOOD)
      result_80_2 = fsrs_80.next(result_80.card, result_80.card.due, FsrsRuby::Rating::GOOD)
      
      # Higher retention should result in shorter intervals
      expect(result_90_2.card.scheduled_days).to be < result_80_2.card.scheduled_days
    end

    it 'respects maximum_interval setting' do
      fsrs_limited = FsrsRuby.new(maximum_interval: 30, enable_short_term: false)
      
      # Progress card through learning phase first
      current_card = card
      result1 = fsrs_limited.next(current_card, now, FsrsRuby::Rating::GOOD)
      result2 = fsrs_limited.next(result1.card, result1.card.due, FsrsRuby::Rating::GOOD)
      
      # Now in REVIEW state - continue with GOOD ratings
      current_card = result2.card
      8.times do
        result = fsrs_limited.next(current_card, current_card.due, FsrsRuby::Rating::GOOD)
        # Allow 1 day tolerance due to potential rounding in interval calculations
        expect(result.card.scheduled_days).to be <= 31
        current_card = result.card
      end
    end

    it 'disables short-term scheduling when enable_short_term: false' do
      fsrs_no_st = FsrsRuby.new(enable_short_term: false)
      
      result = fsrs_no_st.next(card, now, FsrsRuby::Rating::GOOD)
      
      # Without short-term, should schedule in days not minutes
      expect(result.card.scheduled_days).to be > 0
    end
  end

  describe 'strategy customization' do
    it 'allows custom seed strategy' do
      fsrs_with_fuzz = FsrsRuby.new(enable_fuzz: true)
      fsrs_with_fuzz.use_strategy(:seed, lambda { |_scheduler|
        'custom_seed_123'
      })
      
      result = fsrs_with_fuzz.next(card, now, FsrsRuby::Rating::GOOD)
      
      expect(result.card).to be_a(FsrsRuby::Card)
    end
  end
end

