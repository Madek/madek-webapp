require 'spec_helper'

describe MyController do

  before :example do
    @user = FactoryGirl.create :user
    10.times { FactoryGirl.create :media_entry, responsible_user: @user }
    10.times { FactoryGirl.create :collection, responsible_user: @user }
    @user.media_entries.sample(7).each {|me| me.favor_by @user }
    @user.collections.sample(7).each {|c| c.favor_by @user }
  end

  it "dashboard" do
    get :dashboard, nil, { user_id: @user.id }
    assert_template :dashboard
    assert_response :success

    latest_media_entries = assigns(:latest_media_entries)
    expect(latest_media_entries.count).to be == 6
    latest_collections = assigns(:latest_collections)
    expect(latest_collections.count).to be == 6

    favorite_media_entries = assigns(:favorite_media_entries)
    expect(favorite_media_entries.count).to be == 6
    favorite_collections = assigns(:favorite_collections)
    expect(favorite_collections.count).to be == 6
  end

end
