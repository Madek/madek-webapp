require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Collection default Context' do
  given(:user) { create(:user, password: 'password') }
  given(:collection) { create(:collection_with_title, responsible_user: user) }

  background do
    prepare_contexts_for_collection
    sign_in_as user, 'password'
    visit_collection
  end

  scenario 'Choosing default Context' do
    expect_active_tab(I18n.t(:collection_tab_main))
    expect_disabled_save_button
    expect_no_tab('Core')

    click_tab('Credits')
    expect_active_tab('Credits')
    expect_enabled_save_button
    save_layout
    expect_disabled_save_button

    visit_collection
    expect_active_tab(I18n.t(:collection_tab_main))
    expect_tab('Credits')
    expect_tab('Core')
    expect_disabled_save_button

    click_tab('Credits')
    expect_active_tab('Credits')
    expect_disabled_save_button

    click_tab('Werk')
    expect_active_tab('Werk')
    expect_tab('Core')
    expect_enabled_save_button
    save_layout
    expect_disabled_save_button
    page_reload
    expect_active_tab('Werk')
    expect_tab('Core')
    expect_disabled_save_button

    click_tab('Core')
    expect_active_tab('Core')
    expect_enabled_save_button
    save_layout
    expect_disabled_save_button

    visit_collection
    expect_active_tab(I18n.t(:collection_tab_main))
    expect_disabled_save_button
    expect_no_tab('Core')
  end

  def visit_collection
    visit collection_path(collection)
  end

  def prepare_contexts_for_collection
    settings = AppSetting.first
    settings.update_attribute(:contexts_for_collection_extra,
                              ['media_content', 'copyright'])

    create(:meta_datum_text,
           meta_key: MetaKey.find('madek_core:copyright_notice'),
           collection: collection)
  end
end

def click_tab(label)
  find('.ui-tabs .ui-tabs-item a', exact_text: label).click
end

def save_layout
  within('.ui-polybox') do
    find('a', text: I18n.t(:collection_layout_save)).click
  end
end

def page_reload
  page.evaluate_script('window.location.reload(true)')
end

def expect_tab(label)
  expect(page).to have_css('.ui-tabs .ui-tabs-item a', exact_text: label)
end

def expect_no_tab(label)
  expect(page).not_to have_css('.ui-tabs .ui-tabs-item a', text: label)
end

def expect_active_tab(label)
  expect(page).to have_css('.ui-tabs .ui-tabs-item.active a', exact_text: label)
end

def expect_enabled_save_button
  within('.ui-polybox') do
    expect(page).to have_css('a:not([disabled])', text: I18n.t(:collection_layout_save))
  end
end

def expect_disabled_save_button
  within('.ui-polybox') do
    expect(page).to have_css('a[disabled]', text: I18n.t(:collection_layout_saved))
  end
end
