# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventLoggerRails::Event do
  subject(:event) { described_class.new(identifier) }

  before do
    EventLoggerRails.setup do |config|
      config.registered_events = {
        foo: { bar: 'This is an event.' }
      }
    end
  end

  describe 'attributes' do
    context 'when an registered event is provided' do
      let(:identifier) { 'foo.bar' }

      it 'identifer contains the provided identifier' do
        expect(event.identifier).to eq('foo.bar')
      end

      it 'description contains the corresponding description' do
        expect(event.description).to eq('This is an event.')
      end
    end

    context 'when an unregistered event is provided' do
      let(:identifier) { 'foobarbaz' }

      it 'identifer is nil' do
        expect(event.identifier).to be_nil
      end

      it 'description is nil' do
        expect(event.description).to be_nil
      end
    end
  end

  describe '#valid?' do
    subject(:method_call) { event.valid? }

    let(:valid_registered_event) { 'foo.bar' }

    context 'when provided identifier is not a registered event' do
      let(:identifier) { 'foobar' }

      it { is_expected.to be_falsey }
    end

    context 'when provided identifier is a registered event' do
      let(:identifier) { valid_registered_event }

      it { is_expected.to be_truthy }
    end

    context 'when the event_logger_rails.logger_level.invalid event identifier is provided' do
      let(:identifier) { 'event_logger_rails.logger_level.invalid' }

      it { is_expected.to be_truthy }
    end

    context 'when the event_logger_rails.event.unregistered event identifier is provided' do
      let(:identifier) { 'event_logger_rails.event.unregistered' }

      it { is_expected.to be_truthy }
    end

    context 'when the event_logger_rails.event.testing event identifier is provided' do
      let(:identifier) { 'event_logger_rails.event.testing' }

      it { is_expected.to be_truthy }
    end
  end

  describe '#to_h' do
    subject(:method_call) { event.to_h }

    let(:identifier) { 'foo.bar' }

    it { is_expected.to eq({ event_identifier: event.identifier, event_description: event.description }) }
  end

  describe '#to_s' do
    subject(:method_call) { event.to_s }

    let(:identifier) { 'foo.bar' }

    it { is_expected.to eq(identifier) }
  end

  describe '#==' do
    subject(:method_call) { event == other_event }

    let(:identifier) { 'foobar' }

    context 'when the other object is a string' do
      context 'with a value matching the event identifier' do
        let(:other_event) { event }

        it { is_expected.to be_truthy }
      end

      context 'with a value not matching the event identifier' do
        let(:other_event) { 'foobarbaz' }

        it { is_expected.to be_falsey }
      end
    end

    context 'when the other object is another object that can be converted to a string' do
      context 'with a value matching the event identifier' do
        let(:other_event) { described_class.new(event) }

        it { is_expected.to be_truthy }
      end

      context 'with a value not matching the event identifier' do
        let(:other_event) { described_class.new('foobarbaz') }

        it { is_expected.to be_falsey }
      end
    end
  end
end
