require 'spec_helper'

describe ApplicationController do

  before(:each) do
    AppSetting.first || create(:app_setting)
  end

  it 'root' do
    get :root
    assert_template :root
    assert_response :success
  end

  it 'current user' do
    get :root, session: { user_id: FactoryGirl.create(:user).id }
    expect(@controller.current_user).not_to be_nil
  end

  context 'authentication', type: :request do

    it 'error 401 if not logged in' do
      get my_dashboard_path
      assert_response 401
    end

  end

end
