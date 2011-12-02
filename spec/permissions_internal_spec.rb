require 'spec_helper'

describe Permissions do

  context "function mediaresourceuserpermission_disallows" do
    it "should return true if there is a mediaresourceuserpermission that disallows" do
      user = FactoryGirl.create :user
      mediaresource = FactoryGirl.create :mediaresource
      mediaresourceuserpermission = FactoryGirl.create :mediaresourceuserpermission, :user => user, :mediaresource => mediaresource, :maynot_view => true
      (Permissions.mediaresourceuserpermission_disallows :view, mediaresource, user).should == true
    end
    it "should return false if there is no a mediaresourceuserpermission that disallows" do
      user = FactoryGirl.create :user
      mediaresource = FactoryGirl.create :mediaresource
      (Permissions.mediaresourceuserpermission_disallows :view, mediaresource, user).should == false
    end
  end

  context "function mediaresourceuserpermission_allows" do
    it "should return true if there is a mediaresourceuserpermission that allows" do
      user = FactoryGirl.create :user
      mediaresource = FactoryGirl.create :mediaresource
      mediaresourceuserpermission = FactoryGirl.create :mediaresourceuserpermission, :user => user, :mediaresource => mediaresource, :may_view => true
      (Permissions.mediaresourceuserpermission_allows :view, mediaresource, user).should == true
    end
    it "should return false if there is no a mediaresourceuserpermission that allows" do
      user = FactoryGirl.create :user
      mediaresource = FactoryGirl.create :mediaresource
      (Permissions.mediaresourceuserpermission_allows :view, mediaresource, user).should == false
    end
  end

  context "fucntion mediaresourcegrouppermission_allows" do
    it "should return true if there is at least one mediaresourcegrouppermission that allows " do
      user = FactoryGirl.create :user
      usergroup = FactoryGirl.create :usergroup
      usergroup.users << user
      mediaresource = FactoryGirl.create :mediaresource
      mediaresourcegrouppermission = FactoryGirl.create :mediaresourcegrouppermission, :may_view => true, :usergroup => usergroup, :mediaresource => mediaresource
      (Permissions.mediaresourcegrouppermission_allows :view, mediaresource, user).should == true
    end
    it "should return false if there is no mediaresourcegrouppermission that allows " do
      user = FactoryGirl.create :user
      usergroup = FactoryGirl.create :usergroup
      usergroup.users << user
      mediaresource = FactoryGirl.create :mediaresource
      (Permissions.mediaresourcegrouppermission_allows :view, mediaresource, user).should == false
    end
  end

end
