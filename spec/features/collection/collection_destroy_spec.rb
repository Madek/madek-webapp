require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: Collection' do

  describe 'Action: destroy' do

    scenario 'view', browser: :firefox do
      login
      open_dialog
    end

    scenario 'cancel', browser: :firefox do
      login
      open_dialog
      cancel
    end

    scenario 'accept', browser: :firefox do
      login
      open_dialog
      delete
    end

  end

  private

  def cancel
    find('.modal').find('.ui-actions').find('a', text: 'Abbrechen').click
    expect(current_path).to eq collection_path(@collection)
    expect(Collection.exists?(@collection.id)).to eq(true)
  end

  def delete
    find('.modal').find('.ui-actions').find('button', text: 'Löschen').click
    expect(current_path).to eq my_dashboard_path
    expect(Collection.exists?(@collection.id)).to eq(false)
  end

  def open_dialog
    title = I18n.t(:resource_action_destroy, raise: false)
    find('.ui-body-title-actions').find('.button[title="' + title + '"]').click
    expect(current_path).to eq ask_delete_collection_path(@collection)
    within('.modal') do
      expect(page).to have_content 'Set löschen'
      expect(page).to have_content 'Abbrechen'
      expect(page).to have_content @collection.title
      expect(page).to have_content 'Löschen'
    end
  end

  def login
    prepare_data
    sign_in_as @login, @password
    visit collection_path(@collection)
    expect(current_path).to eq collection_path(@collection)
  end

  def prepare_media_entry
    @media_entry = FactoryGirl.create(
      :media_entry,
      responsible_user: @user,
      creator: @user)

    @media_file = FactoryGirl.create(
      :media_file_for_image,
      media_entry: @media_entry)

    FactoryGirl.create(
      :meta_datum_text,
      created_by: @user,
      meta_key: meta_key_title,
      media_entry: @media_entry,
      value: 'Medien Eintrag')
  end

  def prepare_collection
    @collection = Collection.create!(
      get_metadata_and_previews: true,
      responsible_user: @user,
      creator: @user)
    MetaDatum::Text.create!(
      collection: @collection,
      string: 'Mein Titel',
      meta_key: meta_key_title,
      created_by: @user)

    @collection.media_entries << @media_entry
  end

  def prepare_data
    @login = 'user'
    @password = '1234'

    @user = FactoryGirl.create(:user, login: @login, password: @password)

    prepare_media_entry

    prepare_collection
  end

  def meta_key_title
    MetaKey.find_by(id: 'madek_core:title')
  end

end
