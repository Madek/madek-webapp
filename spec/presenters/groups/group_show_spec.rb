require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::Groups::GroupShow do
  it 'dummy' do
    # needed for CI
  end

  it_can_be 'dumped' do
    group = FactoryGirl.create(:group)
    3.times { group.users << FactoryGirl.create(:user) }
    let(:presenter) { described_class.new(group) }
  end
end
