require 'spec_helper'

describe MediaEntryResource do

  it "can be created by it's factory" do
    expect{ FactoryGirl.create :media_entry_resource}.not_to raise_error
  end
end
