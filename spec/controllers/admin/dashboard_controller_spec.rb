require 'spec_helper'

describe Admin::DashboardController do

  context 'authorization' do
    it "raises 401 when user isn't authorized" do
      expect { get :index }.to raise_error(Errors::UnauthorizedError)
    end

    it "raises 403 when user isn't admin" do
      @user = FactoryGirl.create :user
      expect { get :index, nil, user_id: @user.id }
        .to raise_error(Errors::ForbiddenError)
    end

    it 'successful when user has admin rights', type: :controller do
      @user = FactoryGirl.create :admin_user
      get :index, nil, user_id: @user.id
      assert_response :success
      assert_template :admin
    end
  end
end
