require 'spec_helper'

describe "Permissions.resources_permissible_for_user" do

  describe "A public viewable MediaResource" do

    before(:each) do
      @owner = FactoryGirl.create :user
      @media_resource = FactoryGirl.create :media_resource, user: @owner, view: true
      @user = FactoryGirl.create :user
    end

    it "should be included in the users viewable media_resources" do
     (Permissions.resources_permissible_for_user @user, :view).should include @media_resource
    end

    context "the user is not allowed by user permissions" do

      before(:each) do
        FactoryGirl.create :userpermission, user: @user, media_resource: @media_resource, view: false
      end

      it "should be included in the users viewable media_resources" do
        (Permissions.resources_permissible_for_user @user, :view).should include @media_resource
      end

    end
  end


  describe "A non public viewable MediaResource" do 

    before(:each) do
      @owner = FactoryGirl.create :user
      @media_resource = FactoryGirl.create :media_resource, user: @owner, view: false
      @user = FactoryGirl.create :user
    end

    it "should be included in the owners viewable media_resources" do
      (Permissions.resources_permissible_for_user @owner, :view).should include @media_resource
    end

    it "should be included in the viewable_media_resources even if the owner is disallowed by media_resourceuserpermissions"  do
      FactoryGirl.create :userpermission, user: @owner, media_resource: @media_resource, view: false
      (Permissions.resources_permissible_for_user @owner, :view).should include @media_resource
    end


    it "should not be included for an user without any permissions" do
      (Permissions.resources_permissible_for_user @user, :view).should_not include @media_resource
    end

    context "when a userpermission allows the user" do

      before(:each) do
        FactoryGirl.create :userpermission, user: @user, media_resource: @media_resource, view: true
      end

      it "the media_resource should be included" do
        (Permissions.resources_permissible_for_user @user, :view).should include @media_resource
      end

    end

    context "a mediaresourcegrouppermission allows the user to view" do

      before(:each) do
        @group = FactoryGirl.create :group
        @group.users << @user
        FactoryGirl.create :grouppermission, view: true, group: @group, media_resource: @media_resource
      end

      it "should be be included for the user" do
        (Permissions.resources_permissible_for_user @user, :view).should include @media_resource
      end

      context "when a mediaresourceuserpermission denies the user to view" do
        before(:each) do
          FactoryGirl.create :userpermission, user: @user, media_resource: @media_resource, view: false
        end

        it "should not be included for the user" do
        (Permissions.resources_permissible_for_user @user, :view).should_not include @media_resource

        end
      end
    end
  end
end



    

