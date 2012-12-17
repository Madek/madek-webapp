require 'spec_helper'

describe ApplicationController do

  describe "as guest user" do
    it "should respond with success" do
      get :root, {}, {}
      response.should be_success
    end
  end

  describe "as logged in user" do
    before :all do
      FactoryGirl.create :usage_term
      @user = FactoryGirl.create :user
    end
    it "should respond with success" do
      get :root, {}, {user_id: @user.id}
      response.should be_success
    end
  end
  
end
