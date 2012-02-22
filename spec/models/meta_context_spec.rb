require 'spec_helper'

describe "MetaContext" do |mc|

  it "should be producible by a factory" do
    (FactoryGirl.create :meta_context).should_not == nil
  end


end
