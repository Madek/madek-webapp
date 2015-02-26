require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::People::PersonShow do
  it 'dummy' do
    # needed for CI
  end

  it_can_be 'dumped' do
    person = Person.first
    let(:presenter) { described_class.new(person) }
  end
end
