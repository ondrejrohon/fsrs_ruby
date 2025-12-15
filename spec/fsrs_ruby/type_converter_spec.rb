# frozen_string_literal: true

RSpec.describe FsrsRuby::TypeConverter do
  describe '.time' do
    it 'returns Time object as-is' do
      time = Time.now
      result = described_class.time(time)
      expect(result).to eq(time)
    end

    it 'converts integer timestamp to Time' do
      timestamp = 1_234_567_890
      result = described_class.time(timestamp)
      expect(result).to be_a(Time)
      expect(result.to_i).to eq(timestamp)
    end

    it 'converts string to Time' do
      time_string = '2024-01-15T12:00:00Z'
      result = described_class.time(time_string)
      expect(result).to be_a(Time)
      expect(result.to_s).to include('2024-01-15')
    end

    it 'raises error for invalid time' do
      expect { described_class.time([1, 2, 3]) }.to raise_error(ArgumentError, /Invalid time/)
    end
  end

  describe '.state' do
    it 'returns valid integer state as-is' do
      result = described_class.state(FsrsRuby::State::NEW)
      expect(result).to eq(FsrsRuby::State::NEW)
    end

    it 'raises error for invalid integer state' do
      expect { described_class.state(999) }.to raise_error(ArgumentError, /Invalid state/)
    end

    it 'converts string to state constant' do
      result = described_class.state('NEW')
      expect(result).to eq(FsrsRuby::State::NEW)

      result = described_class.state('LEARNING')
      expect(result).to eq(FsrsRuby::State::LEARNING)
    end

    it 'converts symbol to state constant' do
      result = described_class.state(:REVIEW)
      expect(result).to eq(FsrsRuby::State::REVIEW)
    end

    it 'raises error for invalid state type' do
      expect { described_class.state([1, 2]) }.to raise_error(ArgumentError, /Invalid state/)
    end
  end

  describe '.rating' do
    it 'returns valid integer rating as-is' do
      result = described_class.rating(FsrsRuby::Rating::GOOD)
      expect(result).to eq(FsrsRuby::Rating::GOOD)
    end

    it 'raises error for invalid integer rating' do
      expect { described_class.rating(999) }.to raise_error(ArgumentError, /Invalid rating/)
    end

    it 'converts string to rating constant' do
      result = described_class.rating('GOOD')
      expect(result).to eq(FsrsRuby::Rating::GOOD)

      result = described_class.rating('HARD')
      expect(result).to eq(FsrsRuby::Rating::HARD)
    end

    it 'converts symbol to rating constant' do
      result = described_class.rating(:EASY)
      expect(result).to eq(FsrsRuby::Rating::EASY)
    end

    it 'raises error for invalid rating type' do
      expect { described_class.rating([1, 2]) }.to raise_error(ArgumentError, /Invalid rating/)
    end
  end

  describe '.card' do
    it 'returns Card object as-is' do
      card = FsrsRuby::Card.new(due: Time.now)
      result = described_class.card(card)
      expect(result).to eq(card)
    end

    it 'converts hash to Card object' do
      now = Time.now
      card_hash = {
        due: now,
        stability: 5.0,
        difficulty: 3.0,
        elapsed_days: 1,
        scheduled_days: 2,
        learning_steps: 0,
        reps: 3,
        lapses: 1,
        state: FsrsRuby::State::REVIEW,
        last_review: now
      }

      result = described_class.card(card_hash)

      expect(result).to be_a(FsrsRuby::Card)
      expect(result.stability).to eq(5.0)
      expect(result.difficulty).to eq(3.0)
      expect(result.reps).to eq(3)
      expect(result.lapses).to eq(1)
      expect(result.state).to eq(FsrsRuby::State::REVIEW)
    end

    it 'converts hash with minimal fields' do
      now = Time.now
      card_hash = {
        due: now,
        state: 0
      }

      result = described_class.card(card_hash)

      expect(result).to be_a(FsrsRuby::Card)
      expect(result.stability).to eq(0.0)
      expect(result.difficulty).to eq(0.0)
      expect(result.reps).to eq(0)
    end
  end
end
