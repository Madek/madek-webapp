require 'spec_helper'

describe MyController do

  before :example do
    @user = FactoryGirl.create :user
    5.times { FactoryGirl.create :media_entry, responsible_user: @user }
  end

  it 'dashboard' do
    get :dashboard, nil,  user_id: @user.id
    assert_template :dashboard
    assert_response :success
    latest_media_entries = assigns(:latest_media_entries)
    expect(latest_media_entries).not_to be_empty
  end

end
