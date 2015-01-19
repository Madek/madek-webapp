require 'spec_helper'

describe MediaEntriesController do

  before :context do
    user = FactoryGirl.create :user
    user.media_entries << FactoryGirl.create(:media_entry)
  end

  before :example do
    @user = FactoryGirl.create :user
  end

  context 'assigns media entries' do

    after :example do
      assert_response :success
      media_entries = assigns(:media_entries)
      expect(media_entries).to be
      expect(media_entries.count).to be == 1
    end

    it 'latest filter' do
      @user.media_entries << FactoryGirl.create(:media_entry)
      get :index, { responsible: 'true' }, user_id: @user.id
    end

    it 'imported filter' do
      FactoryGirl.create \
        :media_entry,
        responsible_user: FactoryGirl.create(:user),
        creator: @user

      get :index, { imported: 'true' }, user_id: @user.id
    end

    it 'favorite filter' do
      @user.favorite_media_entries << FactoryGirl.create(:media_entry)
      get :index, { favorite: 'true' }, user_id: @user.id
    end

    it 'entrusted filter' do
      FactoryGirl.create \
        :media_entry_user_permission,
        get_metadata_and_previews: true,
        user: @user,
        media_entry: FactoryGirl.create(:media_entry)

      get :index, { entrusted: 'true' }, user_id: @user.id
    end
  end
end
