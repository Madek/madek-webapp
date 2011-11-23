require 'spec_helper'
require 'sqlhelper'

describe MediaEntry do

  it "should be producible by a factory" do
    (FactoryGirl.create :media_entry).should_not == nil
  end


end


