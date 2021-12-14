require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Collection default Context' do
  given(:user) { create(:user, password: 'password') }
  given(:collection) { create(:collection_with_title, responsible_user: user) }
  given(:main_context_id) { 'core' }

  background do
    prepare_contexts_for_collection
    sign_in_as user, 'password'
    visit_collection
  end

  scenario 'Choosing default Context to Credits and then back to the main one' do
    expect_active_tab(I18n.t(:collection_tab_main))
    expect_tab_with_href(I18n.t(:collection_tab_main), collection_path(collection))
    expect_disabled_save_button

    expect_tab_with_href('Credits', context_collection_path(collection, 'copyright'))
    click_tab('Credits')
    expect_active_tab('Credits')
    expect_enabled_save_button
    save_layout
    expect_disabled_save_button

    visit_collection
    expect_tab_with_href(I18n.t(:collection_tab_main),
                         context_collection_path(collection, main_context_id))
    expect_tab_with_href('Credits', collection_path(collection))
    expect_active_tab('Credits')
    expect_disabled_save_button

    visit_context('copyright')
    expect_tab_with_href(I18n.t(:collection_tab_main),
                         context_collection_path(collection, main_context_id))
    expect_tab_with_href('Credits', collection_path(collection))
    expect_active_tab('Credits')
    expect_disabled_save_button

    click_tab(I18n.t(:collection_tab_main))
    expect_active_tab(I18n.t(:collection_tab_main))
    expect_enabled_save_button
    save_layout
    expect_disabled_save_button

    visit_collection
    expect_active_tab(I18n.t(:collection_tab_main))
    expect_tab_with_href(I18n.t(:collection_tab_main), collection_path(collection))
    expect_disabled_save_button

    visit_context(main_context_id)
    expect_active_tab(I18n.t(:collection_tab_main))
    expect_tab_with_href(I18n.t(:collection_tab_main), collection_path(collection))
    expect_tab_with_href('Credits', context_collection_path(collection, 'copyright'))
    expect_disabled_save_button
  end

  def visit_collection
    visit collection_path(collection)
  end

  def visit_context(context_id)
    visit context_collection_path(collection, context_id)
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

def expect_active_tab(label)
  expect(page).to have_css('.ui-tabs .ui-tabs-item.active a', exact_text: label)
end

def generate_href(href)
  server = Capybara.current_session.server
  "http://#{server.host}:#{server.port}#{href}"
end

def expect_tab_with_href(label, href)
  tab = find('.ui-tabs .ui-tabs-item a', exact_text: label)
  expect(tab[:href]).to eq(generate_href(href))
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
