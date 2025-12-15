# frozen_string_literal: true

RSpec.describe 'FsrsRuby Models' do
  describe FsrsRuby::Card do
    it 'can be created with all required values' do
      now = Time.now
      card = FsrsRuby::Card.new(due: now)
      
      expect(card.due).to eq(now)
      expect(card.stability).to eq(0)
      expect(card.difficulty).to eq(0)
      expect(card.elapsed_days).to eq(0)
      expect(card.scheduled_days).to eq(0)
      expect(card.reps).to eq(0)
      expect(card.lapses).to eq(0)
      expect(card.state).to eq(FsrsRuby::State::NEW)
      expect(card.last_review).to be_nil
    end

    it 'can be created with custom values' do
      now = Time.now
      card = FsrsRuby::Card.new(
        due: now,
        stability: 5.5,
        difficulty: 3.2,
        reps: 10,
        state: FsrsRuby::State::REVIEW
      )
      
      expect(card.due).to eq(now)
      expect(card.stability).to eq(5.5)
      expect(card.difficulty).to eq(3.2)
      expect(card.reps).to eq(10)
      expect(card.state).to eq(FsrsRuby::State::REVIEW)
    end
  end

  describe FsrsRuby::ReviewLog do
    it 'can be created with all required fields' do
      now = Time.now
      log = FsrsRuby::ReviewLog.new(
        rating: FsrsRuby::Rating::GOOD,
        state: FsrsRuby::State::NEW,
        due: now,
        stability: 0,
        difficulty: 0,
        elapsed_days: 0,
        last_elapsed_days: 0,
        scheduled_days: 0,
        review: now,
        learning_steps: 0
      )
      
      expect(log.rating).to eq(FsrsRuby::Rating::GOOD)
      expect(log.state).to eq(FsrsRuby::State::NEW)
      expect(log.elapsed_days).to eq(0)
    end
  end

  describe FsrsRuby::RecordLogItem do
    it 'combines card and review log' do
      now = Time.now
      card = FsrsRuby::Card.new(due: now)
      log = FsrsRuby::ReviewLog.new(
        rating: FsrsRuby::Rating::GOOD,
        state: FsrsRuby::State::NEW,
        due: now,
        stability: 0,
        difficulty: 0,
        elapsed_days: 0,
        last_elapsed_days: 0,
        scheduled_days: 0,
        review: now,
        learning_steps: 0
      )
      
      record = FsrsRuby::RecordLogItem.new(card: card, log: log)
      
      expect(record.card).to eq(card)
      expect(record.log).to eq(log)
    end
  end

  describe 'Constants' do
    it 'defines all rating values' do
      expect(FsrsRuby::Rating::AGAIN).to eq(1)
      expect(FsrsRuby::Rating::HARD).to eq(2)
      expect(FsrsRuby::Rating::GOOD).to eq(3)
      expect(FsrsRuby::Rating::EASY).to eq(4)
    end

    it 'defines all state values' do
      expect(FsrsRuby::State::NEW).to eq(0)
      expect(FsrsRuby::State::LEARNING).to eq(1)
      expect(FsrsRuby::State::REVIEW).to eq(2)
      expect(FsrsRuby::State::RELEARNING).to eq(3)
    end
  end

  describe FsrsRuby::State do
    describe '.valid?' do
      it 'returns true for valid states' do
        expect(FsrsRuby::State.valid?(0)).to be true
        expect(FsrsRuby::State.valid?(1)).to be true
        expect(FsrsRuby::State.valid?(2)).to be true
        expect(FsrsRuby::State.valid?(3)).to be true
      end

      it 'returns false for invalid states' do
        expect(FsrsRuby::State.valid?(999)).to be false
        expect(FsrsRuby::State.valid?(-1)).to be false
      end
    end

    describe '.from_string' do
      it 'converts valid string to state' do
        expect(FsrsRuby::State.from_string('NEW')).to eq(FsrsRuby::State::NEW)
        expect(FsrsRuby::State.from_string('LEARNING')).to eq(FsrsRuby::State::LEARNING)
      end

      it 'raises error for invalid string' do
        expect {
          FsrsRuby::State.from_string('INVALID')
        }.to raise_error(ArgumentError, /Invalid state/)
      end
    end

    describe '.to_string' do
      it 'converts state value to string' do
        expect(FsrsRuby::State.to_string(0)).to eq('New')
        expect(FsrsRuby::State.to_string(1)).to eq('Learning')
        expect(FsrsRuby::State.to_string(2)).to eq('Review')
        expect(FsrsRuby::State.to_string(3)).to eq('Relearning')
      end

      it 'raises error for invalid value' do
        expect {
          FsrsRuby::State.to_string(999)
        }.to raise_error(ArgumentError, /Invalid state value/)
      end
    end
  end

  describe FsrsRuby::Rating do
    describe '.valid?' do
      it 'returns true for valid ratings' do
        expect(FsrsRuby::Rating.valid?(0)).to be true
        expect(FsrsRuby::Rating.valid?(1)).to be true
        expect(FsrsRuby::Rating.valid?(4)).to be true
      end

      it 'returns false for invalid ratings' do
        expect(FsrsRuby::Rating.valid?(999)).to be false
        expect(FsrsRuby::Rating.valid?(-1)).to be false
      end
    end

    describe '.from_string' do
      it 'converts valid string to rating' do
        expect(FsrsRuby::Rating.from_string('GOOD')).to eq(FsrsRuby::Rating::GOOD)
        expect(FsrsRuby::Rating.from_string('HARD')).to eq(FsrsRuby::Rating::HARD)
      end

      it 'raises error for invalid string' do
        expect {
          FsrsRuby::Rating.from_string('INVALID')
        }.to raise_error(ArgumentError, /Invalid rating/)
      end
    end

    describe '.to_string' do
      it 'converts rating value to string' do
        expect(FsrsRuby::Rating.to_string(0)).to eq('Manual')
        expect(FsrsRuby::Rating.to_string(1)).to eq('Again')
        expect(FsrsRuby::Rating.to_string(2)).to eq('Hard')
        expect(FsrsRuby::Rating.to_string(3)).to eq('Good')
        expect(FsrsRuby::Rating.to_string(4)).to eq('Easy')
      end

      it 'raises error for invalid value' do
        expect {
          FsrsRuby::Rating.to_string(999)
        }.to raise_error(ArgumentError, /Invalid rating value/)
      end
    end
  end

  describe 'Card#clone' do
    it 'creates a deep copy of the card' do
      now = Time.now
      card = FsrsRuby::Card.new(
        due: now,
        stability: 5.0,
        difficulty: 3.0,
        reps: 10,
        state: FsrsRuby::State::REVIEW,
        last_review: now
      )
      
      cloned = card.clone
      
      expect(cloned).not_to be(card)
      expect(cloned.due).to eq(card.due)
      expect(cloned.stability).to eq(card.stability)
      expect(cloned.difficulty).to eq(card.difficulty)
      expect(cloned.reps).to eq(card.reps)
      expect(cloned.state).to eq(card.state)
    end
  end

  describe 'Card#to_h' do
    it 'converts card to hash' do
      now = Time.now
      card = FsrsRuby::Card.new(
        due: now,
        stability: 5.0,
        difficulty: 3.0,
        reps: 10
      )
      
      hash = card.to_h
      
      expect(hash).to be_a(Hash)
      expect(hash[:due]).to eq(now)
      expect(hash[:stability]).to eq(5.0)
      expect(hash[:difficulty]).to eq(3.0)
      expect(hash[:reps]).to eq(10)
    end
  end

  describe 'ReviewLog#to_h' do
    it 'converts review log to hash' do
      now = Time.now
      log = FsrsRuby::ReviewLog.new(
        rating: FsrsRuby::Rating::GOOD,
        state: FsrsRuby::State::REVIEW,
        due: now,
        stability: 5.0,
        difficulty: 3.0,
        elapsed_days: 1,
        last_elapsed_days: 0,
        scheduled_days: 2,
        learning_steps: 0,
        review: now
      )
      
      hash = log.to_h
      
      expect(hash).to be_a(Hash)
      expect(hash[:rating]).to eq(FsrsRuby::Rating::GOOD)
      expect(hash[:state]).to eq(FsrsRuby::State::REVIEW)
      expect(hash[:stability]).to eq(5.0)
      expect(hash[:difficulty]).to eq(3.0)
    end
  end

  describe FsrsRuby::Parameters do
    describe '#to_h' do
      it 'converts parameters to hash' do
        params = FsrsRuby::Parameters.new(
          request_retention: 0.9,
          maximum_interval: 36500,
          enable_fuzz: true
        )
        
        hash = params.to_h
        
        expect(hash).to be_a(Hash)
        expect(hash[:request_retention]).to eq(0.9)
        expect(hash[:maximum_interval]).to eq(36500)
        expect(hash[:enable_fuzz]).to eq(true)
        expect(hash[:w]).to be_an(Array)
        expect(hash[:learning_steps]).to be_an(Array)
      end
    end
  end
end

