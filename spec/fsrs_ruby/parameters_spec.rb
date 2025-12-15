# frozen_string_literal: true

RSpec.describe FsrsRuby::Parameters do
  describe 'initialization' do
    it 'creates parameters with default values' do
      params = FsrsRuby::Parameters.new
      
      expect(params.request_retention).to eq(0.9)
      expect(params.maximum_interval).to eq(36500)
      expect(params.w.length).to eq(21)
      expect(params.enable_fuzz).to eq(false) # Default is false
      expect(params.enable_short_term).to eq(true)
    end

    it 'accepts custom request_retention' do
      params = FsrsRuby::Parameters.new(request_retention: 0.85)
      
      expect(params.request_retention).to eq(0.85)
    end

    it 'accepts custom maximum_interval' do
      params = FsrsRuby::Parameters.new(maximum_interval: 365)
      
      expect(params.maximum_interval).to eq(365)
    end

    it 'accepts custom w parameters (21 params)' do
      custom_w = Array.new(21) { |i| i * 0.1 }
      params = FsrsRuby::Parameters.new(w: custom_w)
      
      expect(params.w).to eq(custom_w)
      expect(params.w.length).to eq(21)
    end

    it 'accepts enable_fuzz flag' do
      params = FsrsRuby::Parameters.new(enable_fuzz: false)
      
      expect(params.enable_fuzz).to eq(false)
    end

    it 'accepts enable_short_term flag' do
      params = FsrsRuby::Parameters.new(enable_short_term: false)
      
      expect(params.enable_short_term).to eq(false)
    end

    it 'accepts custom learning_steps' do
      custom_steps = ['1m', '5m', '15m']
      params = FsrsRuby::Parameters.new(learning_steps: custom_steps)
      
      expect(params.learning_steps).to eq(custom_steps)
    end

    it 'accepts custom relearning_steps' do
      custom_steps = ['5m', '30m']
      params = FsrsRuby::Parameters.new(relearning_steps: custom_steps)
      
      expect(params.relearning_steps).to eq(custom_steps)
    end
  end

  describe 'parameter migration via ParameterUtils' do
    it 'auto-fills from 17 parameters to 21' do
      v4_params = Array.new(17) { |i| i * 0.1 }
      params = FsrsRuby::ParameterUtils.generate_parameters(w: v4_params)
      
      expect(params.w.length).to eq(21)
      # First 17 should be modified according to migration rules
      # Last 4 are added
    end

    it 'auto-fills from 19 parameters to 21' do
      v5_params = Array.new(19) { |i| i * 0.1 }
      params = FsrsRuby::ParameterUtils.generate_parameters(w: v5_params)
      
      expect(params.w.length).to eq(21)
    end

    it 'uses provided 21 parameters with clipping' do
      v6_params = Array.new(21) { |i| i * 0.1 }
      params = FsrsRuby::ParameterUtils.generate_parameters(w: v6_params)
      
      expect(params.w.length).to eq(21)
    end

    it 'uses defaults for invalid parameter count' do
      invalid_params = Array.new(15) { |i| i * 0.1 }
      
      # Should warn and use defaults, not raise
      params = FsrsRuby::ParameterUtils.generate_parameters(w: invalid_params)
      
      expect(params.w).to eq(FsrsRuby::Constants::DEFAULT_WEIGHTS)
    end
  end

  describe 'learning steps' do
    it 'uses default learning steps' do
      params = FsrsRuby::Parameters.new
      
      expect(params.learning_steps).to eq(['1m', '10m'])
    end

    it 'uses default relearning steps' do
      params = FsrsRuby::Parameters.new
      
      expect(params.relearning_steps).to eq(['10m'])
    end

    it 'allows empty learning steps' do
      params = FsrsRuby::Parameters.new(learning_steps: [])
      
      expect(params.learning_steps).to eq([])
    end
  end

  describe 'parameter acceptance' do
    it 'accepts various request_retention values' do
      [0.7, 0.8, 0.9, 0.95, 0.99].each do |retention|
        params = FsrsRuby::Parameters.new(request_retention: retention)
        expect(params.request_retention).to eq(retention)
      end
    end

    it 'accepts various maximum_interval values' do
      [1, 365, 36500].each do |max_interval|
        params = FsrsRuby::Parameters.new(maximum_interval: max_interval)
        expect(params.maximum_interval).to eq(max_interval)
      end
    end

    it 'validates w parameters contain valid numbers' do
      # check_parameters validates this
      valid_params = Array.new(21, 1.0)
      expect {
        FsrsRuby::ParameterUtils.check_parameters(valid_params)
      }.not_to raise_error
      
      invalid_params = [Float::NAN] + Array.new(20, 1.0)
      expect {
        FsrsRuby::ParameterUtils.check_parameters(invalid_params)
      }.to raise_error(ArgumentError, /Non-finite/)
    end

    it 'validates w parameters length' do
      expect {
        FsrsRuby::ParameterUtils.check_parameters(Array.new(15, 1.0))
      }.to raise_error(ArgumentError, /Invalid parameter length/)
      
      # Valid lengths: 17, 19, 21
      expect {
        FsrsRuby::ParameterUtils.check_parameters(Array.new(17, 1.0))
      }.not_to raise_error
      
      expect {
        FsrsRuby::ParameterUtils.check_parameters(Array.new(19, 1.0))
      }.not_to raise_error
      
      expect {
        FsrsRuby::ParameterUtils.check_parameters(Array.new(21, 1.0))
      }.not_to raise_error
    end
  end
end

