require 'spec_helper'

describe Admin::DashboardController do

  context 'authorization' do
    it 'renders 401 error page with appropriate status code ' \
       "when user isn't authorized" do
      get :index
      assert_response :unauthorized
      expect(response.body).to have_selector('h1.title-xxl', text: 'Unauthorized')
    end

    it 'renders 403 error page with appropriate status code ' \
       "when user isn't admin" do
      @user = FactoryGirl.create :user
      get :index, nil, user_id: @user.id
      assert_response :forbidden
      expect(response.body).to have_selector('h1.title-xxl', text: 'Forbidden')
    end

    it 'successful when user has admin rights' do
      @user = FactoryGirl.create :admin_user
      get :index, nil, user_id: @user.id
      assert_response :success
      assert_template :admin
    end
  end
end
