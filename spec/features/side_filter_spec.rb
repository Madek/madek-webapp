require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Side Filter' do

  describe 'Show' do

    before :example do
      @login = 'user'
      @password = '1234'
      @title_0 = 'Title 0'
      @title_1 = 'Title 1'

      prepare_data
      login
      visit media_entries_path
    end

    it 'open accordion and select filter', browser: :firefox do
      open_filterbar

      expect(page).to have_content(@title_0)
      expect(page).to have_content(@title_1)

      context_key = ContextKey.find_by_meta_key_id(@meta_key_keywords.id)

      item_link_0 = find_item_element(first_level: 'Core',
                                      second_level: context_key.label,
                                      third_level: @keyword_0.term,
                                      open: true)
      item_link_0.click

      expect(page).to have_content(@title_0)
      expect(page).to have_no_content(@title_1)

      item_link_0 = find_item_element(first_level: 'Core',
                                      second_level: context_key.label,
                                      third_level: @keyword_0.term,
                                      open: false)
      item_link_0.click

      expect(page).to have_content(@title_0)
      expect(page).to have_content(@title_1)

      item_link_1 = find_item_element(first_level: 'Core',
                                      second_level: context_key.label,
                                      third_level: @keyword_1.term,
                                      open: false)
      item_link_1.click

      expect(page).to have_no_content(@title_0)
      expect(page).to have_content(@title_1)

      item_link_0 = find_item_element(first_level: 'Core',
                                      second_level: context_key.label,
                                      third_level: @keyword_0.term,
                                      open: false)
      item_link_0.click

      expect(page).to have_no_content(@title_0)
      expect(page).to have_no_content(@title_1)
    end

    it 'check correct position sorting of 2nd level', browser: :firefox do
      open_filterbar

      context_key_authors = ContextKey.find_by_meta_key_id(@meta_key_authors.id)
      context_key_keywords = ContextKey.find_by_meta_key_id(@meta_key_keywords.id)
      expect(context_key_authors.position)
        .not_to be == context_key_keywords.position

      root_ul = find('.ui-side-filter-list')
      section_li = root_ul.find('.ui-side-filter-lvl1-item', text: 'Core')
      section_a = section_li.first('.ui-accordion-toggle')
      section_a.click

      expect(section_li.all('.ui-side-filter-lvl2-item').map(&:text))
        .to be == [context_key_authors,
                   context_key_keywords].sort_by(&:position).map(&:label)
    end

    private

    def login
      sign_in_as @login, @password
    end

    def find_item_element(first_level:, second_level:, third_level:, open:)
      root_ul = find('.ui-side-filter-list')
      section_li = root_ul.find('.ui-side-filter-lvl1-item', text: first_level)
      section_a = section_li.first('.ui-accordion-toggle')
      section_a.click if open
      section_ul = section_li.first('.ui-side-filter-lvl2')
      sub_section_li = section_ul.first('.ui-side-filter-lvl2-item',
                                        text: second_level)
      sub_section_a = sub_section_li.first('.ui-accordion-toggle')
      sub_section_a.click if open
      sub_section_li.find('.ui-side-filter-lvl3')
        .find('.ui-side-filter-lvl3-item', text: third_level)
        .first('.link, .ui_link')
    end

    def open_filterbar(inside = page)
      wait_until do
        inside.within('.ui-filterbar') { find('.button', text: 'Filtern').click }
      end
    end

    def prepare_data
      @user = FactoryGirl.create(:user, login: @login, password: @password)

      @meta_key_keywords = MetaKey.find_by(id: 'madek_core:keywords')
      @meta_key_authors = MetaKey.find_by(id: 'madek_core:authors')

      @keyword_0 = @meta_key_keywords.keywords[0]
      @keyword_1 = @meta_key_keywords.keywords[1]

      meta_key_title = MetaKey.find_by(id: 'madek_core:title')

      keywords0 = [@keyword_0]
      keywords1 = [@keyword_1]

      create_media_entry(keywords0, @title_0, meta_key_title, @meta_key_keywords)
      create_media_entry(keywords1, @title_1, meta_key_title, @meta_key_keywords)
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
