require 'spec_helper'

describe MyController do

  before :example do
    @user = FactoryGirl.create :user
  end

  it "dashboard" do
    get :dashboard, nil, { user_id: @user.id }
    assert_template :dashboard
    assert_response :success
  end

end
