module UIHelpers
  def select_entry_from_autocomplete_list(index_or_text = 0, input_name = '[query]')
    page.execute_script %Q{ $('[name="#{input_name}"]').trigger('keydown') }
    selector = if index_or_text.is_a?(Integer)
      %Q{ ul.ui-autocomplete li.ui-menu-item:eq(#{index_or_text}) }
    else
      %Q{ ul.ui-autocomplete li.ui-menu-item:contains(\'#{index_or_text}\') }
    end

    expect(page).to have_selector('ul.ui-autocomplete li.ui-menu-item')
    page.execute_script %Q{ $("#{selector}").trigger('mouseenter').click() }

    page.execute_script %Q{ $('.ui-menu-item:first').trigger('mouseenter').click() }
  end
end
