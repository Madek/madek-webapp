require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::People::PersonShow do
  it 'dummy' do
    # needed for CI
  end

  it_can_be 'dumped' do
    user = FactoryGirl.create(:user)
    let(:presenter) do
      described_class.new(user.person,
                          User.where('RANDOM()').limit(1))
    end
  end
end
