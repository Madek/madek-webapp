require 'spec_helper'

describe Permissions do

  before :each do
    @media_set = FactoryGirl.create :media_set
    @user = FactoryGirl.create :user
  end

  context "function userpermission_disallows" do

    it "should return not nil if there is a userpermission that disallows" do
      FactoryGirl.create :userpermission, user: @user, resource: @media_set, maynot_view: true
      (Permissions.userpermission_disallows :view, @media_set, @user).should_not == nil
    end

    it "should return nil if there is no userpermission that disallows" do
      FactoryGirl.create :userpermission, :user => @user, :resource => @media_set, :maynot_view => false
      (Permissions.userpermission_disallows :view, @media_set, @user).should == nil
    end


  end

  context "function userpermission_allows " do

    it "should return not nil if there is a userpermission that allows " do
      FactoryGirl.create :userpermission, :user => @user, :resource => @media_set, :may_view => true
      (Permissions.userpermission_allows :view, @media_set, @user).should_not == nil
    end

    it "should return nil if there is no userpermission that allows " do
      FactoryGirl.create :userpermission, :user => @user, :resource => @media_set, :may_view => false
      (Permissions.userpermission_allows :view, @media_set, @user).should == nil
    end

  end

  context "function grouppermission_allows" do

    before :each do
      @group = FactoryGirl.create :group
      @group.users << @user
    end

    it "should return nil if there is no grouppermission that allows " do
      FactoryGirl.create :grouppermission, group: @group, resource: @media_set, may_view: false
      (Permissions.grouppermission_allows :view, @media_set, @user).should == nil
    end
      
    it "should return not nil if there is a grouppermission that allows " do
      FactoryGirl.create :grouppermission, group: @group, resource: @media_set, may_view: true
      (Permissions.grouppermission_allows :view, @media_set, @user).should_not == nil
    end


  end

end
