require 'spec_helper'

describe Permission do

  it "should be producible by a factory" do
    (FactoryGirl.create :permission).should_not == nil
  end

  context "and empty permission" do

    before :each do 
      @permission = (FactoryGirl.create :permission)
    end

    it "should be setable to allow view"  do
      Permission.authorized?(@permission.subject,:view,@permission.resource).should == false
      @permission.set_actions(:view)
      @permission.save!
      Permission.authorized?(@permission.subject,:view,@permission.resource).should == true
    end

  end

end
