require 'spec_helper'

describe MediaEntries::Duplicator::Configuration do
  describe 'validation' do
    context 'when some option has no boolean value' do
      it 'raises an error' do
        expect { described_class.new(copy_meta_data: 'foo') }
          .to raise_error(TypeError,
                          'Configuration option copy_meta_data must have a boolean value.')
      end
    end

    context 'when configuration key is incorrect' do
      it 'raises an error' do
        expect { described_class.new(incorrect_option: true) }
          .to raise_error(KeyError,
                          'Configuration key incorrect_option is unsupported.')
      end
    end
  end
end
