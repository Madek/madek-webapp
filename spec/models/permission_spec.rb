require 'spec_helper'

describe Permission do

  it "should be producible by a factory" do
    (FactoryGirl.create :permission).should_not == nil
  end

end
