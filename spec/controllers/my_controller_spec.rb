require 'spec_helper'

describe MyController do

  before :example do
    @user = FactoryGirl.create :user

    10.times { FactoryGirl.create :media_entry, responsible_user: @user }
    10.times { FactoryGirl.create :collection, responsible_user: @user }
    10.times { FactoryGirl.create :filter_set, responsible_user: @user }

    10.times { FactoryGirl.create :media_entry, creator: @user }

    @user.media_entries.sample(7).each { |me| me.favor_by @user }
    @user.collections.sample(7).each { |c| c.favor_by @user }
    @user.filter_sets.sample(7).each { |fs| fs.favor_by @user }
  end

  it 'dashboard' do
    get :dashboard, nil,  user_id: @user.id
    assert_template :dashboard
    assert_response :success

    latest_media_entries = assigns(:latest_media_entries)
    expect(latest_media_entries.count).to be == 6
    expect(latest_media_entries.first).to eq @user.media_entries.reorder('updated_at DESC').first

    latest_collections = assigns(:latest_collections)
    expect(latest_collections.count).to be == 6
    expect(latest_collections.first).to eq @user.collections.reorder('updated_at DESC').first

    latest_filter_sets = assigns(:latest_filter_sets)
    expect(latest_filter_sets.count).to be == 6
    expect(latest_filter_sets.first).to eq @user.filter_sets.reorder('updated_at DESC').first

    latest_imports = assigns(:latest_imports)
    expect(latest_imports.count).to be == 6
    expect(latest_imports.first).to eq @user.created_media_entries.reorder('created_at DESC').first

    favorite_media_entries = assigns(:favorite_media_entries)
    expect(favorite_media_entries.count).to be == 6
    favorite_collections = assigns(:favorite_collections)
    expect(favorite_collections.count).to be == 6
    favorite_filter_sets = assigns(:favorite_filter_sets)
    expect(favorite_filter_sets.count).to be == 6
  end

end
