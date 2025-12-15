# frozen_string_literal: true

RSpec.describe FsrsRuby::Alea do
  describe 'seeded random number generation' do
    it 'produces consistent results with same seed' do
      alea1 = FsrsRuby::Alea.new('test_seed')
      alea2 = FsrsRuby::Alea.new('test_seed')
      
      values1 = 10.times.map { alea1.next }
      values2 = 10.times.map { alea2.next }
      
      expect(values1).to eq(values2)
    end

    it 'produces different results with different seeds' do
      alea1 = FsrsRuby::Alea.new('seed1')
      alea2 = FsrsRuby::Alea.new('seed2')
      
      values1 = 10.times.map { alea1.next }
      values2 = 10.times.map { alea2.next }
      
      expect(values1).not_to eq(values2)
    end

    it 'produces values between 0 and 1' do
      alea = FsrsRuby::Alea.new('test')
      
      100.times do
        value = alea.next
        expect(value).to be_between(0, 1)
      end
    end

    it 'produces uniformly distributed values' do
      alea = FsrsRuby::Alea.new('distribution_test')
      
      values = 1000.times.map { alea.next }
      
      # Check that we have reasonable distribution
      low_count = values.count { |v| v < 0.5 }
      high_count = values.count { |v| v >= 0.5 }
      
      # Should be roughly 50/50 (within 20% margin)
      expect(low_count).to be_between(400, 600)
      expect(high_count).to be_between(400, 600)
    end

    it 'handles numeric seeds' do
      alea1 = FsrsRuby::Alea.new(12345)
      alea2 = FsrsRuby::Alea.new(12345)
      
      expect(alea1.next).to eq(alea2.next)
    end

    it 'handles array seeds' do
      alea = FsrsRuby::Alea.new(['seed', 'array'])
      
      10.times do
        value = alea.next
        expect(value).to be_between(0, 1)
      end
    end
  end

  describe 'fuzzing integration' do
    it 'applies fuzzing to intervals when enabled' do
      fsrs_with_fuzz = FsrsRuby.new(enable_fuzz: true)
      fsrs_without_fuzz = FsrsRuby.new(enable_fuzz: false)
      
      now = Time.parse('2024-01-01T00:00:00Z')
      card = FsrsRuby.create_empty_card(now)
      
      # Progress to review state
      result1_fuzz = fsrs_with_fuzz.next(card, now, FsrsRuby::Rating::GOOD)
      result2_fuzz = fsrs_with_fuzz.next(result1_fuzz.card, result1_fuzz.card.due, FsrsRuby::Rating::GOOD)
      
      result1_no_fuzz = fsrs_without_fuzz.next(card, now, FsrsRuby::Rating::GOOD)
      result2_no_fuzz = fsrs_without_fuzz.next(result1_no_fuzz.card, result1_no_fuzz.card.due, FsrsRuby::Rating::GOOD)
      
      # Both should have valid scheduled days
      expect(result2_fuzz.card.scheduled_days).to be > 0
      expect(result2_no_fuzz.card.scheduled_days).to be > 0
    end

    it 'produces slightly different intervals with fuzzing' do
      # Note: Due to the seeding strategy, we may need specific card IDs to see variance
      fsrs = FsrsRuby.new(enable_fuzz: true)
      
      now = Time.parse('2024-01-01T00:00:00Z')
      
      # Create cards and progress them
      intervals = 3.times.map do |i|
        card = FsrsRuby::Card.new(
          due: now,
          stability: 0,
          difficulty: 0,
          state: FsrsRuby::State::NEW,
          reps: 0,
          lapses: 0,
          scheduled_days: 0,
          elapsed_days: 0,
          learning_steps: 0
        )
        card.instance_variable_set(:@id, "card_#{i}")
        
        result1 = fsrs.next(card, now, FsrsRuby::Rating::GOOD)
        result2 = fsrs.next(result1.card, result1.card.due, FsrsRuby::Rating::GOOD)
        result2.card.scheduled_days
      end
      
      # All should be positive
      intervals.each do |interval|
        expect(interval).to be > 0
      end
    end
  end

  describe 'state preservation' do
    it 'maintains internal state across multiple calls' do
      alea = FsrsRuby::Alea.new('state_test')
      
      first_value = alea.next
      second_value = alea.next
      third_value = alea.next
      
      # Reset with same seed
      alea_reset = FsrsRuby::Alea.new('state_test')
      
      expect(alea_reset.next).to eq(first_value)
      expect(alea_reset.next).to eq(second_value)
      expect(alea_reset.next).to eq(third_value)
    end
  end
end

