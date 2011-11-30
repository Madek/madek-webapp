require 'spec_helper'

describe Userpermission do

  it "should be producible by a factory" do
    (FactoryGirl.create :Userpermission).should_not == nil
  end

  context "consistency constraints " do
    before :each do
     @user  = FactoryGirl.create :user
     @resource = FactoryGirl.create :media_set, :owner => (FactoryGirl.create :user)
    end

    it "should remove mediaresourceuserpermission if the user is destroyed" do
      id = (FactoryGirl.create :mediaresourceuserpermission, :user => u, :mediaresource => mr).id
      (Userppermission.find_by_id id).should_not be_nil
      u.destroy
      (Userppermission.find_by_id id).should be_nil
    end

    it "should remove mediaresourceuserpermission if the mediaresource is destroyed" do
      id = (FactoryGirl.create :mediaresourceuserpermission, :user => u, :mediaresource => mr).id
      (Userppermission.find_by_id id).should_not be_nil
      mr.destroy
      (Userppermission.find_by_id id).should be_nil
    end

  end

end
