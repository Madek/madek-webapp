require 'spec_helper'

describe SessionsController do

  context "POST #sign in" do

    before :context do
      @user = FactoryGirl.create :user
    end

    it "successful sign in and redirect to default path" do

      post :sign_in, login: @user.login, password: @user.password

      expect(session[:user_id]).to be
      assert_redirected_to my_dashboard_path
      expect(flash[:success]).to eq "Sie haben sich angemeldet."

    end

    it "successful logout" do

      post :sign_in, login: @user.login, password: @user.password
      post :sign_out

      expect(session[:user_id]).to be_nil # session should be reseted
      expect(flash[:notice]).to eq "Sie haben sich abgemeldet."
      assert_redirected_to root_path

    end

  end

end
