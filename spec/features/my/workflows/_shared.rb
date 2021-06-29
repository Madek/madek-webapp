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

  def check_is_common(meta_key_id)
    find_section(meta_key_id)
      .check('is_common')
  end

  def set_fixed_value(meta_key_id, value)
    check_is_common(meta_key_id)
    fill_in meta_key_id, with: value
  end
end
