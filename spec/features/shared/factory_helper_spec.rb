require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

module FactoryHelper

  def prepare_collection(title)
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

  def login
    sign_in_as @login, @password
  end

  def prepare_user
    @login = 'user'
    @password = '1234'
    @user = FactoryBot.create(:user, login: @login, password: @password)
  end

  def prepare_media_entry(title)
    media_entry = FactoryBot.create(
      :media_entry,
      responsible_user: @user,
      creator: @user)

    FactoryBot.create(
      :media_file_for_image,
      media_entry: @media_entry)

    FactoryBot.create(
      :meta_datum_text,
      created_by: @user,
      meta_key: meta_key_title,
      media_entry: media_entry,
      value: title)

    media_entry
  end

  def set_subtitle(media_entry, subtitle)
    MetaDatum::Text.create!(
      media_entry: media_entry,
      string: subtitle,
      meta_key: meta_key('madek_core:subtitle'),
      created_by: @user)
  end

  def set_keywords(media_entry, keyword_list)
    keywords = keyword_list.map do |keyword|
      result = Keyword.find_by(term: keyword)
      if result
        result
      else
        FactoryBot.create(
          :keyword,
          term: keyword,
          meta_key: meta_key('madek_core:keywords'))
      end
    end

    FactoryBot.create(
      :meta_datum_keywords,
      keywords: keywords,
      media_entry: media_entry,
      meta_key: meta_key('madek_core:keywords'))
  end

  def meta_key_title
    meta_key('madek_core:title')
  end

  def meta_key(type)
    MetaKey.find_by(id: type)
  end

end
