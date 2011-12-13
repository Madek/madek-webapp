require 'spec_helper'

describe Person do

  it "should be producible by a factory" do
    (FactoryGirl.create :person).should_not == nil
  end

end
