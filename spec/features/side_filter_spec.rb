require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Side Filter' do

  describe 'Show' do

    it 'open accordion and select filter', browser: :firefox  do

      @login = 'user'
      @password = '1234'
      @title_0 = 'Title 0'
      @title_1 = 'Title 1'

      prepare_data
      login
      visit media_entries_path

      open_filterbar
      expect(page).to have_content(@title_0)
      expect(page).to have_content(@title_1)

      item_link_0 = find_item_element @keyword_0.term, true
      item_link_0.click

      expect(page).to have_content(@title_0)
      expect(page).to have_no_content(@title_1)

      item_link_0 = find_item_element @keyword_0.term, false
      item_link_0.click

      expect(page).to have_content(@title_0)
      expect(page).to have_content(@title_1)

      item_link_1 = find_item_element @keyword_1.term, false
      item_link_1.click

      expect(page).to have_no_content(@title_0)
      expect(page).to have_content(@title_1)

      item_link_0 = find_item_element @keyword_0.term, false
      item_link_0.click

      expect(page).to have_no_content(@title_0)
      expect(page).to have_no_content(@title_1)
    end

    private

    def login
      sign_in_as @login, @password
    end

    def find_item_element(name, open)
      root_ul = find('ul.ui-side-filter-list')
      section_li = root_ul.first('li.ui-side-filter-lvl1-item')
      section_a = section_li.first('a')
      section_a.click if open
      section_ul = section_li.first('ul')
      sub_section_li = section_ul.first('li.ui-side-filter-lvl2-item')
      sub_section_a = sub_section_li.first('a')
      sub_section_a.click if open
      subsection_ul = sub_section_li.first('ul')
      xpath = './/li[contains(@class,"ui-side-filter-lvl3-item")]'
      xpath = xpath + '/span/span[contains(.,"' + name + '")]'
      subsection_ul.first(:xpath, xpath).first(:xpath, '..')
    end

    def open_filterbar(inside = page)
      inside.within('.ui-filterbar') { find('.button', text: 'Filtern').click }
    end

    def prepare_data
      # FactoryGirl.create(:app_settings)
      @user = FactoryGirl.create(:user, login: @login, password: @password)

      meta_key_keywords = MetaKey.find_by(id: 'madek_core:keywords')
      @keyword_0 = meta_key_keywords.keywords[0]
      @keyword_1 = meta_key_keywords.keywords[1]

      meta_key_title = MetaKey.find_by(id: 'madek_core:title')

      keywords0 = [@keyword_0]
      keywords1 = [@keyword_1]

      create_media_entry(keywords0, @title_0, meta_key_title, meta_key_keywords)
      create_media_entry(keywords1, @title_1, meta_key_title, meta_key_keywords)
    end

    def create_media_entry(keywords, title, meta_key_title, meta_key_keywords)
      media_entry = FactoryGirl.create(
        :media_entry,
        responsible_user: @user,
        creator: @user)

      FactoryGirl.create(
        :meta_datum_text,
        created_by: @user,
        meta_key: meta_key_title,
        media_entry: media_entry,
        value: title)

      FactoryGirl.create(
        :meta_datum_keywords,
        created_by: @user,
        meta_key: meta_key_keywords,
        media_entry: media_entry,
        keywords: keywords)
    end

  end

end
