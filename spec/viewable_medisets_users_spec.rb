require 'spec_helper'

describe "viewable_mediasets_users" do

  describe "A public viewable media_set" do

    before(:each) do
      @owner = FactoryGirl.create :user
      @media_set = FactoryGirl.create :media_set, perm_public_may_view:  true, owner: @owner 
      @user = FactoryGirl.create :user
    end

    it "should be included in the users viewable media_sets" do
      @user.viewable_media_sets.should include @media_set
    end

    context "when the user is not allowed by user permissions" do

      before(:each) do
        FactoryGirl.create :userpermission, user: @user, media_resource: @media_set, maynot_view: true
      end

      it "should be included in the users viewable media_sets" do
        @user.viewable_media_sets.should include @media_set
      end

    end
  end


  describe "A non public viewable media_set" do 

    before(:each) do
      @owner = FactoryGirl.create :user
      @media_set = FactoryGirl.create :media_set, perm_public_may_view:  false, owner: @owner 
      @user = FactoryGirl.create :user
    end

    it "should be included in the owners viewable media_sets" do
      @owner.viewable_media_sets.should include @media_set
    end

    it "should be included in the viewable_media_sets even if the owner is disallowed by media_setuserpermissions"  do
      FactoryGirl.create :userpermission, user: @user, media_resource: @media_set, maynot_view: true
      @owner.viewable_media_sets.should include @media_set
    end


    it "should not be included for an user without any permissions" do
      @user.viewable_media_sets.should_not include @media_set
    end

    context "when a userpermission allows the user" do

      before(:each) do
        FactoryGirl.create :userpermission, user: @user, media_resource: @media_set, may_view: true
      end

      it "the media_set should be included" do
        @user.viewable_media_sets.should include @media_set
      end

    end

    context "when a grouppermission allows the user to view" do

      before(:each) do
        @group = FactoryGirl.create :group
        @group.users << @user
        FactoryGirl.create :grouppermission, may_view: true, group: @group, media_resource: @media_set
      end

      it "should be be included for the user" do
        @user.viewable_media_sets.should include @media_set
      end

      context "when a mediaresourceuserpermission denies the user to view" do

        before(:each) do
          FactoryGirl.create :userpermission, may_view: false, maynot_view: true, media_resource: @media_set, user: @user
        end

        it "should not be included for the user" do
          @user.viewable_media_sets.should_not include @media_set
        end
      end
    end
  end
end



    

