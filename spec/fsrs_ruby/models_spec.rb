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
end

