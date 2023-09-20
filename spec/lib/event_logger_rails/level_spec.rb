# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLoggerRails::Level do
  subject(:level) { described_class.new(logger_level) }

  describe '#valid?' do
    subject(:method_call) { level.valid? }

    let(:valid_logger_level) { :info }

    before do
      EventLoggerRails.setup do |config|
        config.logger_levels = [valid_logger_level]
      end
    end

    context 'when provided level is not a configured logger level' do
      let(:logger_level) { :foobar }

      it { is_expected.to be_falsey }
    end

    context 'when provided level is a configured logger level' do
      let(:logger_level) { valid_logger_level }

      it { is_expected.to be_truthy }
    end
  end

  describe '#to_s' do
    subject(:method_call) { level.to_s }

    let(:logger_level) { :info }

    it { is_expected.to eq(logger_level.to_s) }
  end

  describe '#to_sym' do
    subject(:method_call) { level.to_sym }

    let(:logger_level) { :info }

    it { is_expected.to eq(logger_level) }
  end
end
