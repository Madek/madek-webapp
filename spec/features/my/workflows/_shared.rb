module Helpers
  def expand_section(translation_key)
    within(find('h3', text: I18n.t(translation_key))) { click_button }
  end

  def find_section(meta_key_id)
    find(:xpath, "//label[@for='emk_#{meta_key_id}']")
      .ancestor('.ui-form-group')
  end

  def uncheck_is_mandatory(meta_key_id)
    find_section(meta_key_id)
      .uncheck('is_mandatory')
  end
end
