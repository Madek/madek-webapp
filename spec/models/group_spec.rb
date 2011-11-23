require 'spec_helper'

describe Group do

  it "should be producible by a factory" do
    (FactoryGirl.create :group).should_not == nil
  end

end
