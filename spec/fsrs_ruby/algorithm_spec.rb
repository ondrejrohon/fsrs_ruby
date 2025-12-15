# frozen_string_literal: true

RSpec.describe FsrsRuby::Algorithm do
  let(:fixtures) { load_fixtures }
  let(:algorithm) { FsrsRuby::Algorithm.new }

  describe '#init_difficulty' do
    it 'matches TypeScript output for all ratings' do
      ts_values = fixtures['algorithm']['init_difficulty']

      expect(algorithm.init_difficulty(FsrsRuby::Rating::AGAIN)).to be_close_to_ts(ts_values['again'])
      expect(algorithm.init_difficulty(FsrsRuby::Rating::HARD)).to be_close_to_ts(ts_values['hard'])
      expect(algorithm.init_difficulty(FsrsRuby::Rating::GOOD)).to be_close_to_ts(ts_values['good'])
      expect(algorithm.init_difficulty(FsrsRuby::Rating::EASY)).to be_close_to_ts(ts_values['easy'])
    end
  end

  describe '#init_stability' do
    it 'matches TypeScript output for all ratings' do
      ts_values = fixtures['algorithm']['init_stability']

      expect(algorithm.init_stability(FsrsRuby::Rating::AGAIN)).to be_close_to_ts(ts_values['again'])
      expect(algorithm.init_stability(FsrsRuby::Rating::HARD)).to be_close_to_ts(ts_values['hard'])
      expect(algorithm.init_stability(FsrsRuby::Rating::GOOD)).to be_close_to_ts(ts_values['good'])
      expect(algorithm.init_stability(FsrsRuby::Rating::EASY)).to be_close_to_ts(ts_values['easy'])
    end
  end

  describe '#forgetting_curve' do
    it 'matches TypeScript output' do
      ts_test = fixtures['algorithm']['forgetting_curve']
      input = ts_test['input']

      result = algorithm.forgetting_curve(
        algorithm.parameters.w,
        input['elapsed_days'],
        input['stability']
      )

      expect(result).to be_close_to_ts(ts_test['output'])
    end
  end
end
