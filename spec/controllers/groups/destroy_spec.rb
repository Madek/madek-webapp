require 'spec_helper'

describe GroupsController do
  include Controllers::Shared
  render_views
  
  before :each do
    @user1 = FactoryGirl.create :user, person: FactoryGirl.create(:person)
    @user2 = FactoryGirl.create :user, person: FactoryGirl.create(:person)
  end

  describe "DELETE" do

    it "should delete the group if I'm the only member left" do
      group = FactoryGirl.create :group
      group.users << @user1
      delete :destroy, {:format => :json, :id => group.id}, valid_session(@user1)
      response.success?.should be_true
    end

    it "should not delete the group if I'm not a member and there is only one member left" do
      group = FactoryGirl.create :group
      group.users << [@user2]
      lambda {delete :destroy, {:format => :json, :id => group.id}, valid_session(@user1)}.should raise_error
    end

    it "should not delete the group if I'm a member but not the only one" do
      group = FactoryGirl.create :group
      group.users << [@user1, @user2]
      delete :destroy, {:format => :json, :id => group.id}, valid_session(@user1)
      response.success?.should be_false
    end
  end
end

