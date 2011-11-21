require 'spec_helper'

describe User do

  it "should be producible by a factory" do
    (FactoryGirl.create :user).should_not == nil
  end

end
