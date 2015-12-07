require 'spec_helper'
require Rails.root.join 'spec',
                        'controllers',
                        'shared',
                        'media_resources',
                        'authorization.rb'
require Rails.root.join 'spec',
                        'controllers',
                        'shared',
                        'media_resources',
                        'custom_url_redirects.rb'

describe MediaEntriesController do

  before :example do
    @user = FactoryGirl.create :user
  end

  it_performs 'authorization'

  it 'publish' do
    media_entry = \
      create :media_entry_with_image_media_file,
             creator: @user, responsible_user: @user, is_published: false

    @user.unpublished_media_entries.first
    expect(@user.unpublished_media_entries.first.id).to eq media_entry.id
    expect(media_entry.is_published).to be false

    post :publish, { id: media_entry.id }, user_id: @user.id
    expect(response.redirect?).to be true
    expect(flash[:success]).to eq 'Entry was published!'

    media_entry.reload
    expect(media_entry.is_published).to be true
    expect(@user.published_media_entries.first.id).to eq media_entry.id
    expect(@user.published_media_entries.count).to be 1
    expect(@user.unpublished_media_entries.count).to be 0
  end

  it 'delete' do
    media_entry = create :media_entry_with_image_media_file,
                         creator: @user, responsible_user: @user

    expect { delete :destroy, { id: media_entry.id }, user_id: @user.id }
      .to change { MediaEntry.count }.by(-1)

    expect(response).to redirect_to my_dashboard_path

  end

  it 'delete unpublished' do
    media_entry = create :media_entry_with_image_media_file,
                         creator: @user, responsible_user: @user,
                         is_published: false

    expect { delete :destroy, { id: media_entry.id }, user_id: @user.id }
      .to change { MediaEntry.unscoped.count }.by(-1)

    expect(response).to redirect_to my_dashboard_path

  end

  it_handles_properly 'redirection'
end
