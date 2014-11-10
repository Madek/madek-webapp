require 'spec_helper'

describe CollectionResource do

  it "can be created by it's factory" do
    expect{ FactoryGirl.create :collection_resource}.not_to raise_error
  end
end
