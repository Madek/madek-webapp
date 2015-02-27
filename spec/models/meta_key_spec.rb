require 'spec_helper'

describe MetaKey do
  describe '.object_types' do
    it 'returns an array with unique and sorted values' do
      expect(described_class.object_types)
        .to eq(described_class.object_types.uniq)

      expect(described_class.object_types)
        .to eq(described_class.object_types.sort)
    end
  end
end
