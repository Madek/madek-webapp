require 'spec_helper'

describe Keyword do

  before :each do
    3.times do
      FactoryGirl.create :keyword
    end
  end

  describe 'class methods' do

    context 'search' do
      it 'finds existing resources' do
        string = Keyword.first.to_s
        expect(Keyword.search(string).count('*')).to be >= 1
      end

      it 'prevents sql injection' do
        string = "string ' with quotes"
        expect { Keyword.search(string) }.not_to raise_error
      end
    end

  end
end
