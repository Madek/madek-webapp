require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

module BasicDataHelper

  def prepare_user(admin: false)
    @login = 'User'
    @password = '1234'
    person = FactoryBot.create(:person, first_name: @login)
    @user = FactoryBot.create(
      :user,
      person: person,
      login: @login,
      password: @password)
    Admin.create(user: @user) if admin
  end

  def login
    sign_in_as @login, @password
  end

  def click_action_button(icon)
    find('.ui-body-title-actions')
      .find('.icon-' + icon)
      .click
  end

  def create_media_entry(title)
    media_entry = FactoryBot.create(
      :media_entry,
      get_metadata_and_previews: true,
      responsible_user: @user,
      creator: @user)
    FactoryBot.create(
      :media_file_for_image,
      media_entry: media_entry)
    MetaDatum::Text.create!(
      media_entry: media_entry,
      string: title,
      meta_key: meta_key_title,
      created_by: @user)
    media_entry
  end

  def create_collection(title)
    collection = Collection.create!(
      get_metadata_and_previews: true,
      responsible_user: @user,
      creator: @user)
    MetaDatum::Text.create!(
      collection: collection,
      string: title,
      meta_key: meta_key_title,
      created_by: @user)
    collection
  end

  def meta_key_title
    MetaKey.find_by(id: 'madek_core:title')
  end

end
