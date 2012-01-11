require 'spec_helper'

describe "viewable_mediaresources_users" do

  before :all do
     DataFactory.create_small_dataset
    @permissionset_view_false  = FactoryGirl.create :permissionset, view: false, download: false, edit: false, manage: false
    @permissionset_view_true  = FactoryGirl.create :permissionset, view: true, download: false, edit: false, manage: false
  end



  describe "A public viewable MediaResource" do

    before(:each) do
      @owner = FactoryGirl.create :user
      @media_resource = FactoryGirl.create :media_resource, owner: @owner, permissionset: @permissionset_view_true
      @user = FactoryGirl.create :user
    end

    it "should be included in the users viewable media_resources" do
      @user.viewable_media_resources.should include @media_resource
    end

    context "the user is not allowed by user permissions" do

      before(:each) do
        FactoryGirl.create :userpermission, user: @user, media_resource: @media_resource, permissionset: @permissionset_view_false
      end

      it "should be included in the users viewable media_resources" do
        @user.viewable_media_resources.should include @media_resource
      end

    end
  end


  describe "A non public viewable MediaResource" do 

    before(:each) do
      @owner = FactoryGirl.create :user
      @media_resource = FactoryGirl.create :media_resource, owner: @owner, permissionset: @permissionset_view_false
      @user = FactoryGirl.create :user
    end

    it "should be included in the owners viewable media_resources" do
      @owner.viewable_media_resources.should include @media_resource
    end

    it "should be included in the viewable_media_resources even if the owner is disallowed by media_resourceuserpermissions"  do
      FactoryGirl.create :userpermission, user: @owner, media_resource: @media_resource, permissionset: @permissionset_view_false
      @owner.viewable_media_resources.should include @media_resource
    end


    it "should not be included for an user without any permissions" do
      #binding.pry
      @user.viewable_media_resources.should_not include @media_resource
    end

    context "when a userpermission allows the user" do

      before(:each) do
        FactoryGirl.create :userpermission, user: @user, media_resource: @media_resource, permissionset: @permissionset_view_true
      end

      it "the media_resource should be included" do
        @user.viewable_media_resources.should include @media_resource
      end

    end

    context "a mediaresourcegrouppermission allows the user to view" do

      before(:each) do
        @group = FactoryGirl.create :group
        @group.users << @user
        FactoryGirl.create :grouppermission, permissionset: @permissionset_view_true, group: @group, media_resource: @media_resource
      end

      it "should be be included for the user" do
        @user.viewable_media_resources.should include @media_resource
      end

      context "when a mediaresourceuserpermission denies the user to view" do
        before(:each) do
          FactoryGirl.create :userpermission, user: @user, media_resource: @media_resource, permissionset: @permissionset_view_false
        end

        it "should not be included for the user" do
          @user.viewable_media_resources.should_not include @media_resource
        end
      end
    end
  end
end



    

