require 'spec_helper'

describe User do

  it "should be producible by a factory" do
    (FactoryGirl.create :user).should_not == nil
  end

  it "should be destroyable" do
    expect{ (FactoryGirl.create :user).destroy }.not_to raise_error
  end

  context "permissions" do

    describe "A public viewable Mediaresource" do

      before(:each) do
        @owner = FactoryGirl.create :user
        @media_resource = FactoryGirl.create :media_resource, user: @owner, view: true
        @user = FactoryGirl.create :user
      end

      it "should be viewalbe by an unrelated user" do
        @user.authorized?(:view , @media_resource).should == true
      end

      context "the user is not allowed by user permissions" do

        before(:each) do
          FactoryGirl.create :userpermission, user: @user, media_resource: @media_resource, view: false
        end

        it "should be viewable by the user" do
          @user.authorized?(:view, @media_resource).should == true
        end

      end
    end


    describe "A non public viewable Mediaresource" do 


      before(:each) do
        @owner = FactoryGirl.create :user
        @media_resource = FactoryGirl.create :media_resource, user: @owner, view: false
        @user = FactoryGirl.create :user
      end

      it "can be viewed by its owner"  do
        @owner.authorized?(:view , @media_resource).should == true
      end

      it "can be viewed by its owner even if the owner is disallowed by a userpermission"  do
        FactoryGirl.create :userpermission, user: @owner, media_resource: @media_resource, view: false
        @owner.authorized?(:view , @media_resource).should == true
      end

      it "should not be viewable by an user without any permissions" do
        @user.authorized?(:view , @media_resource).should == false
      end

      context "when a userpermission allows the user" do

        before(:each) do
          FactoryGirl.create :userpermission, user: @user, media_resource: @media_resource, view: true
        end

        it "should be be viewable by the user" do
          @user.authorized?(:view , @media_resource).should == true
        end

      end

      context "a mediaresourcegrouppermission allows the user to view" do

        before(:each) do
          @group = FactoryGirl.create :group
          @group.users << @user
          FactoryGirl.create :grouppermission, view: true, group: @group, media_resource: @media_resource
        end

        it "should be be viewable for the user" do
          @user.authorized?(:view , @media_resource).should == true
        end

        context "when a userpermission denies the user to view" do
          before(:each) do
            FactoryGirl.create :userpermission, user: @user, media_resource: @media_resource, view: false
          end

          it "should not be viewable for the user" do
            @user.authorized?(:view , @media_resource).should == false
          end
        end
      end
    end

  end

end
