require 'spec_helper'

describe Admin::DashboardController do

  context 'authorization' do
    it "redirects to 401 error page when user isn't admin" do
      @user = FactoryGirl.create :user
      get :index, nil, user_id: @user.id
      assert_response :unauthorized
    end

    it 'successful when user has admin rights' do
      @user = FactoryGirl.create :admin_user
      get :index, nil, user_id: @user.id
      assert_response :success
      assert_template :admin
    end
  end
end
