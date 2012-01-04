require 'spec_helper'

describe "Permissions" do

  describe "A public viewable Mediaresource" do

    before(:each) do
      @owner = FactoryGirl.create :user
      @media_set = FactoryGirl.create :media_set, perm_public_may_view:  true, owner: @owner 
      @user = FactoryGirl.create :user
    end

    it "should be viewalbe by an unrelated user" do
      (Permissions.authorized? @user, :view , @media_set).should == true
    end

    context "the user is not allowed by user permissions" do

      before(:each) do
        FactoryGirl.create :userpermission, user: @user, media_resource: @media_set, maynot_view: true
      end

      it "should be viewable by the user" do
        (Permissions.authorized? @user, :view, @media_set).should == true
      end

    end
  end


  describe "A non public viewable Mediaresource" do 


    before(:each) do
      @owner = FactoryGirl.create :user
      @media_set = FactoryGirl.create :media_set, perm_public_may_view:  false, owner: @owner 
      @user = FactoryGirl.create :user
    end

    it "can be viewed by its owner"  do
      (Permissions.authorized? @owner, :view , @media_set).should == true
    end

    it "can be viewed by its owner even if the owner is disallowed by a userpermission"  do
      FactoryGirl.create :userpermission, user: @user, media_resource: @media_set, maynot_view: true
      (Permissions.authorized? @owner, :view , @media_set).should == true
    end

    it "should not be viewable by an user without any permissions" do
      (Permissions.authorized? @user, :view , @media_set).should == false
    end

    context "when a userpermission allows the user" do

      before(:each) do
        FactoryGirl.create :userpermission, user: @user, media_resource: @media_set, may_view: true
      end

      it "should be be viewable by the user" do
        (Permissions.authorized? @user, :view , @media_set).should == true
      end

    end

    context "a mediaresourcegrouppermission allows the user to view" do

      before(:each) do
        @group = FactoryGirl.create :group
        @group.users << @user
        FactoryGirl.create :grouppermission, may_view: true, group: @group, media_resource: @media_set
      end

      it "should be be viewable for the user" do
        (Permissions.authorized? @user, :view , @media_set).should == true
      end

      context "when a mediaresourceuserpermission denies the user to view" do

        before(:each) do
          FactoryGirl.create :userpermission, may_view: false, maynot_view: true, media_resource: @media_set, user: @user
        end

        it "should not be viewable for the user" do
          (Permissions.authorized? @user, :view , @media_set).should == false
        end
      end
    end
  end
end

