require 'spec_helper'

describe Permission do

  it "should be producible by a factory" do
    (FactoryGirl.create :permission).should_not == nil
  end

  context "an 'empty' permission" do

    before :each do 
      @permission = (FactoryGirl.create :permission)
    end

    it "should not be vieable by default" do
      Permission.authorized?(@permission.subject, :view, @permission.media_resource).should == false
    end

    it "should be setable to allow view"  do
      @permission.set_actions(:view => true)
      @permission.save!
      Permission.authorized?(@permission.subject, :view, @permission.media_resource).should == true
    end

  end

end
