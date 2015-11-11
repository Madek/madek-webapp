require 'spec_helper'

describe ApplicationController do

  include ::Controllers::Shared

  before :each do
    begin
      AppSettings.create id: 0
    rescue
      # ignore
    end
  end

  describe "as guest user" do
    it "should respond with success" do
      get :root, {}, {}
      expect(response).to be_success
    end
  end

  describe "as logged in user" do
    before :each do
      FactoryGirl.create :usage_term
      @user = FactoryGirl.create :user
    end
    it "should redirect to my dashboard" do
      get :root, {}, valid_session(@user)
      expect(response).to redirect_to(my_dashboard_path)
    end
  end
  
end
