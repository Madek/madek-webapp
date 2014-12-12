require 'spec_helper'

describe ApiClient do

  it 'should be producible by a factory' do
    expect { FactoryGirl.create :api_client }.not_to raise_error
  end

  context 'an existing Collection' do

    before :each do
      @api_client = FactoryGirl.create :api_client
    end

    it 'responds_to authorization_header and returns something that looks like basic auth header ' do
      expect(@api_client.authorization_header).to match /^Authorization:\s+Basic/
    end

  end

end
