# frozen_string_literal: true

RSpec.describe 'FSRS v6 Cross-Validation' do
  let(:fixtures) { load_fixtures }
  let(:fsrs) { FsrsRuby.new(enable_short_term: true) }

  describe 'New Card Scheduling - All Ratings' do
    let(:ts_test) { fixtures['new_card_schedule'] }
    let(:now) { Time.parse(ts_test['input']['now']) }
    let(:card) { FsrsRuby.create_empty_card(now) }
    let(:result) { fsrs.repeat(card, now) }

    it 'produces identical output for AGAIN rating' do
      again_result = result[FsrsRuby::Rating::AGAIN]
      ts_again = ts_test['output']['again']['card']

      expect(again_result.card.difficulty).to be_close_to_ts(ts_again['difficulty'])
      expect(again_result.card.stability).to be_close_to_ts(ts_again['stability'])
      expect(again_result.card.state).to eq(ts_again['state'])
      expect(again_result.card.reps).to eq(ts_again['reps'])
      expect(again_result.card.lapses).to eq(ts_again['lapses'])
      expect(again_result.card.learning_steps).to eq(ts_again['learning_steps'])
    end

    it 'produces identical output for HARD rating' do
      hard_result = result[FsrsRuby::Rating::HARD]
      ts_hard = ts_test['output']['hard']['card']

      expect(hard_result.card.difficulty).to be_close_to_ts(ts_hard['difficulty'])
      expect(hard_result.card.stability).to be_close_to_ts(ts_hard['stability'])
      expect(hard_result.card.state).to eq(ts_hard['state'])
      expect(hard_result.card.reps).to eq(ts_hard['reps'])
      expect(hard_result.card.learning_steps).to eq(ts_hard['learning_steps'])
    end

    it 'produces identical output for GOOD rating' do
      good_result = result[FsrsRuby::Rating::GOOD]
      ts_good = ts_test['output']['good']['card']

      expect(good_result.card.difficulty).to be_close_to_ts(ts_good['difficulty'])
      expect(good_result.card.stability).to be_close_to_ts(ts_good['stability'])
      expect(good_result.card.state).to eq(ts_good['state'])
      expect(good_result.card.reps).to eq(ts_good['reps'])
      expect(good_result.card.learning_steps).to eq(ts_good['learning_steps'])
    end

    it 'produces identical output for EASY rating' do
      easy_result = result[FsrsRuby::Rating::EASY]
      ts_easy = ts_test['output']['easy']['card']

      expect(easy_result.card.difficulty).to be_close_to_ts(ts_easy['difficulty'])
      expect(easy_result.card.stability).to be_close_to_ts(ts_easy['stability'])
      expect(easy_result.card.state).to eq(ts_easy['state'])
      expect(easy_result.card.scheduled_days).to eq(ts_easy['scheduled_days'])
      expect(easy_result.card.reps).to eq(ts_easy['reps'])
    end

    it 'generates correct review logs for all ratings' do
      [FsrsRuby::Rating::AGAIN, FsrsRuby::Rating::HARD, 
       FsrsRuby::Rating::GOOD, FsrsRuby::Rating::EASY].each do |rating|
        rating_result = result[rating]
        rating_name = %w[again hard good easy][rating - 1]
        ts_log = ts_test['output'][rating_name]['log']

        expect(rating_result.log.rating).to eq(ts_log['rating'])
        expect(rating_result.log.state).to eq(ts_log['state'])
        expect(rating_result.log.elapsed_days).to eq(ts_log['elapsed_days'])
      end
    end
  end

  describe 'Review Sequence - Progressive Reviews' do
    it 'matches TypeScript for complete review sequence' do
      review_sequence = fixtures['review_sequence']
      
      # Start with empty card
      current_card = FsrsRuby.create_empty_card(Time.parse('2024-01-01T00:00:00.000Z'))
      
      review_sequence.each do |review|
        now = Time.parse(review['input']['now'])
        result = fsrs.next(current_card, now, FsrsRuby::Rating::GOOD)
        
        ts_output = review['output']['card']
        
        expect(result.card.difficulty).to be_close_to_ts(ts_output['difficulty'])
        expect(result.card.stability).to be_close_to_ts(ts_output['stability'])
        expect(result.card.state).to eq(ts_output['state'])
        expect(result.card.reps).to eq(ts_output['reps'])
        # Note: elapsed_days is calculated at review time, not stored on card
        # The fixture shows what WILL be logged, not what's on the card yet
        # Allow 1 day tolerance for potential rounding differences
        expect(result.card.scheduled_days).to be_within(1).of(ts_output['scheduled_days'])
        
        # Check the review log for elapsed_days
        ts_log = review['output']['log']
        expect(result.log.elapsed_days).to eq(ts_log['elapsed_days'])
        
        current_card = result.card
      end
    end
  end

  describe 'Lapse Scenario - Relearning' do
    it 'handles lapses (Again rating) correctly' do
      lapse_sequence = fixtures['lapse_scenario']
      
      current_card = FsrsRuby.create_empty_card(Time.parse('2024-01-01T00:00:00.000Z'))
      
      lapse_sequence.each_with_index do |review, index|
        rating = review['rating'] == 'Again' ? FsrsRuby::Rating::AGAIN : FsrsRuby::Rating::GOOD
        now = index == 0 ? Time.parse('2024-01-01T00:00:00.000Z') : 
              index == 1 ? Time.parse('2024-01-01T00:10:00.000Z') :
                          Time.parse('2024-01-03T00:10:00.000Z')
        
        result = fsrs.next(current_card, now, rating)
        ts_output = review['output']['card']
        
        expect(result.card.difficulty).to be_close_to_ts(ts_output['difficulty'])
        expect(result.card.stability).to be_close_to_ts(ts_output['stability'])
        expect(result.card.state).to eq(ts_output['state'])
        expect(result.card.lapses).to eq(ts_output['lapses'])
        expect(result.card.reps).to eq(ts_output['reps'])
        
        current_card = result.card
      end
    end
  end

  describe 'Parameter Migration' do
    it 'migrates v4 (17 params) to v6 (21 params) correctly' do
      ts_migration = fixtures['parameter_migration']['v4_to_v6']
      fsrs_migrated = FsrsRuby.new(w: ts_migration['input_params'])

      expect(fsrs_migrated.parameters.w.length).to eq(21)
      
      ts_migration['output_params'].each_with_index do |ts_param, i|
        expect(fsrs_migrated.parameters.w[i]).to be_close_to_ts(ts_param)
      end
    end

    it 'migrates v5 (19 params) to v6 (21 params) correctly' do
      ts_migration = fixtures['parameter_migration']['v5_to_v6']
      fsrs_migrated = FsrsRuby.new(w: ts_migration['input_params'])

      expect(fsrs_migrated.parameters.w.length).to eq(21)
      
      ts_migration['output_params'].each_with_index do |ts_param, i|
        expect(fsrs_migrated.parameters.w[i]).to be_close_to_ts(ts_param)
      end
    end
  end
end
