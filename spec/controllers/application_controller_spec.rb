require 'spec_helper'

describe ApplicationController do

  it "root" do
    get :root
    assert_template :root
    assert_response :success
  end

  it "current user" do
    get :root, nil, { user_id: FactoryGirl.create(:user).id }
    expect(@controller.current_user).not_to be_nil
  end

  context "authentication", type: :request do

    it "redirects to root if not logged in" do
      get my_dashboard_path
      assert_redirected_to root_path
    end

  end

end
