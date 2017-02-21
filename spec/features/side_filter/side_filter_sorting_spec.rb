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

    it 'check correct position sorting of 2nd level' do
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
        .to be == [@meta_key_authors,
                   context_key_keywords].sort_by(&:position).map(&:label)
    end

  end

end
