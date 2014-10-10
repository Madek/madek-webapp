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
      expect(response).to be_success
    end

    it "should not delete the group if I'm not a member and there is only one member left" do
      group = FactoryGirl.create :group
      group.users << [@user2]
      expect { delete :destroy, {:format => :json, :id => group.id}, valid_session(@user1) }.to raise_error
    end

    it "should not delete the group if I'm a member but not the only one" do
      group = FactoryGirl.create :group
      group.users << [@user1, @user2]
      delete :destroy, {:format => :json, :id => group.id}, valid_session(@user1)
      expect(response).not_to be_success
    end
  end
end

