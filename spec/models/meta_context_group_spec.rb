require 'spec_helper'

describe MetaContextGroup do
  
  it "should be producible by a factory" do
    (FactoryGirl.create :meta_context_group).should_not == nil
  end

end
