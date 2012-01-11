require 'spec_helper'

describe Userpermission do

  it "should be producible by a factory" do
    (FactoryGirl.create :userpermission).should_not == nil
  end

  context "consistency constraints " do
    before :each do
     @user  = FactoryGirl.create :user
     @media_resource = FactoryGirl.create :media_resource, :owner => (FactoryGirl.create :user)
    end

    it "should remove userpermissions if the user is destroyed" do
      id = (FactoryGirl.create :userpermission, :user => @user, :media_resource => @media_resource).id
      (Userpermission.find_by_id id).should_not be_nil
      @user.destroy
      (Userpermission.find_by_id id).should be_nil
    end

    it "should remove userpermissions if the resource is destroyed" do
      id = (FactoryGirl.create :userpermission, :user => @user, :media_resource => @media_resource ).id
      (Userpermission.find_by_id id).should_not be_nil
      @media_resource.destroy
      (Userpermission.find_by_id id).should be_nil
    end

  end

end
