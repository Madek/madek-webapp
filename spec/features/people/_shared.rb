require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

def expect_person_detail(attr, new_values)
  expect(page).to have_content(
    I18n.t("person_show_#{attr}") + ' ' + new_values.fetch(attr)
  )
end

def expect_preview(text)
  provider, label = text.split(': ')
  within('.preview', text: label) do
    expect(page).to have_css('.ui-authority-control-badge', text: "#{provider}:")
    expect(page).to have_css('a', text: label)
  end
end

def expect_just_a_link(text)
  expect(page).to have_css('.preview a', text: text)
end

def add_uri(uri)
  click_button I18n.t('person_edit_add_uri_btn')
  find_field('person[external_uris][]', with: '').set(uri)
end
