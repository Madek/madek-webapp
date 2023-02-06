require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

def login
  sign_in_as @login, @password
end

def find_sub_section(first_level:, second_level:, open:)
  root_ul = find('.ui-side-filter-list')
  section_li = root_ul.find('.ui-side-filter-lvl1-item', text: first_level)
  section_a = section_li.first('.ui-accordion-toggle')
  section_a.click if open
  section_ul = section_li.first('.ui-side-filter-lvl2')
  section_ul.first('.ui-side-filter-lvl2-item', text: second_level)
end

def find_item_element(first_level:, second_level:, third_level:, open:)
  sub_section_li = find_sub_section(
    first_level: first_level,
    second_level: second_level,
    open: open)
  sub_section_a = sub_section_li.first('.ui-accordion-toggle')
  sub_section_a.click if open
  sub_section_li.find('.ui-side-filter-lvl3')
    .find('.ui-side-filter-lvl3-item', text: third_level)
    .first('.link, .ui_link')
end

def find_checkbox(first_level:, second_level:, open:)
  sub_section_li = find_sub_section(
    first_level: first_level,
    second_level: second_level,
    open: open)
  sub_section_li.first('.ui-any-value')
end

def open_filterbar(inside = page)
  # Hover on title to make sure no flyout covers the button.
  find('.title-xl').hover
  wait_until do
    inside.within('.ui-filterbar') do
      find('.button', text: 'Filtern').click
    end
  end
end

def prepare_data
  @user = FactoryBot.create(:user, login: @login, password: @password)

  @meta_key_keywords = MetaKey.find_by(id: 'madek_core:keywords')
  @meta_key_authors = MetaKey.find_by(id: 'madek_core:authors')

  @keyword_0 = @meta_key_keywords.keywords.find_by_term('Durchgang')
  expect(@keyword_0).to be
  @keyword_1 = @meta_key_keywords.keywords.find_by_term('Kontrast vorne')
  expect(@keyword_1).to be

  @meta_key_title = MetaKey.find_by(id: 'madek_core:title')

  @keywords0 = [@keyword_0]
  @keywords1 = [@keyword_1]

  prepare_media_entries
end

def prepare_media_entries
  create_media_entry(
    @keywords0,
    @title_0,
    false)
  create_media_entry(
    @keywords1,
    @title_1,
    false)
  create_media_entry(
    [],
    @title_2,
    true)
end

def create_media_file(use_movie)
  if use_movie
    FactoryBot.create(:media_file_for_movie)
  else
    FactoryBot.create(:media_file_for_image)
  end
end

def create_media_entry(keywords, title, use_movie)
  media_file = create_media_file(use_movie)
  media_entry = FactoryBot.create(
    :media_entry,
    responsible_user: @user,
    creator: @user,
    media_file: media_file)

  FactoryBot.create(
    :meta_datum_text,
    created_by: @user,
    meta_key: @meta_key_title,
    media_entry: media_entry,
    value: title)

  FactoryBot.create(
    :meta_datum_keywords,
    created_by: @user,
    meta_key: @meta_key_keywords,
    media_entry: media_entry,
    keywords: keywords)
end
