require_relative './_shared'

feature 'Side Filter' do

  describe 'Show' do

    before :example do
      @login = 'user'
      @password = '1234'
      @title_0 = 'Title 0'
      @title_1 = 'Title 1'
      @title_2 = 'Title 2'

      prepare_data
      login
      visit media_entries_path
    end

    it 'open accordion and select filter' do
      open_filterbar

      expect(page).to have_content(@title_0)
      expect(page).to have_content(@title_1)
      expect(page).to have_content(@title_2)

      context_key = ContextKey.find_by_meta_key_id(@meta_key_keywords.id)

      item_link_0 = find_item_element(first_level: 'Core',
                                      second_level: context_key.label,
                                      third_level: @keyword_0.term,
                                      open: true)
      item_link_0.click

      expect(page).to have_content(@title_0)
      expect(page).to have_no_content(@title_1)
      expect(page).to have_no_content(@title_2)

      item_link_0 = find_item_element(first_level: 'Core',
                                      second_level: context_key.label,
                                      third_level: @keyword_0.term,
                                      open: false)
      item_link_0.click

      expect(page).to have_content(@title_0)
      expect(page).to have_content(@title_1)
      expect(page).to have_content(@title_2)

      item_link_1 = find_item_element(first_level: 'Core',
                                      second_level: context_key.label,
                                      third_level: @keyword_1.term,
                                      open: false)
      item_link_1.click

      expect(page).to have_no_content(@title_0)
      expect(page).to have_content(@title_1)
      expect(page).to have_no_content(@title_2)

      item_link_0 = find_item_element(first_level: 'Core',
                                      second_level: context_key.label,
                                      third_level: @keyword_0.term,
                                      open: false)
      item_link_0.click

      expect(page).to have_no_content(@title_0)
      expect(page).to have_no_content(@title_1)
      expect(page).to have_no_content(@title_2)

      item_link_0 = find_item_element(first_level: 'Datei',
                                      second_level: 'Medientyp',
                                      third_level: 'image',
                                      open: true)
      item_link_0.click

      expect(page).to have_no_content(@title_0)
      expect(page).to have_no_content(@title_1)
      expect(page).to have_no_content(@title_2)

      checkbox = find_checkbox(
        first_level: 'Core',
        second_level: context_key.label,
        open: false)
      checkbox.click

      expect(page).to have_content(@title_0)
      expect(page).to have_content(@title_1)
      expect(page).to have_no_content(@title_2)

      item_link_0 = find_item_element(first_level: 'Datei',
                                      second_level: 'Medientyp',
                                      third_level: 'image',
                                      open: false)
      item_link_0.click

      expect(page).to have_content(@title_0)
      expect(page).to have_content(@title_1)
      expect(page).to have_content(@title_2)

      item_link_0 = find_item_element(first_level: 'Datei',
                                      second_level: 'Medientyp',
                                      third_level: 'video',
                                      open: false)
      item_link_0.click

      expect(page).to have_no_content(@title_0)
      expect(page).to have_no_content(@title_1)
      expect(page).to have_content(@title_2)
    end

  end

end
