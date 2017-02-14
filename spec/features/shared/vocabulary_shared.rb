module VocabularyShared

  def check_title(title)
    find('.ui-body-title-label', text: title)
  end

  def check_tabs(tabs)
    within('.app-body-ui-container') do

      expect(page).to have_selector('.ui-tabs-item', count: tabs.length)

      tabs.each do |tab|
        element = find('.ui-tabs-item', text: I18n.t(tab[:key]))

        if tab[:active]
          element.assert_matches_selector('[class*=active]')
        else
          element.assert_not_matches_selector('[class*=active]')
        end
      end
    end
  end
end
