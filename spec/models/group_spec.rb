require 'spec_helper'

describe Group do

  it "should be producible by a factory" do
    (FactoryGirl.create :group).should_not == nil
  end


  context "users and group realations" do

    before :each do
      @group = FactoryGirl.create :group
      @user = FactoryGirl.create :user
    end

    it "the user should not be included by default" do
      @group.users(true).should_not include @user
    end

    it "should be possible to add a user" do
      @group.users << @user
      @group.users(true).should include @user
    end

    it "should be possible to remove a user" do
      @group.users << @user
      @group.users(true).should include @user
      @group.users.delete @user
      @group.users(true).should_not include @user
    end

    context "referential integrity " do

      it "the row in groups_users should be deleted automatically when deleting the user on a database level" do
        @group.users << @user

        @group.users(true).should include @user
        SQLHelper.execute_sql "DELETE FROM users WHERE id = #{@user.id};"
        @group.users(true).should_not include @user
      end
    
      it "the row in groups_users should be deleted automatically when deleting the user on a database level" do
        @group.users << @user
        @user.groups(true).should include @group
        SQLHelper.execute_sql "DELETE FROM groups WHERE id = #{@group.id};"
        @user.groups(true).should_not include @group
      end

    end

  end

end
