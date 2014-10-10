require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'meta_data', 'shared.rb')

feature 'MetaData' do
  include Features::MetaData::Shared

  # NB: in case of failure:  the affected field and meta_datum is hard to get by
  # see the logging and debugging comment towards the end of the feature

  background do
    @current_user = sign_in_as 'normin'
  end

  scenario 'Changing all meta-data fields of a media entry',
    browser: :firefox do
    @media_entry = FactoryGirl.create :media_entry_with_image_media_file, user: @current_user
    visit media_entry_path(@media_entry)
    click_on_button 'Metadaten editieren'

    # change the value of each meta-data field of each context
    @meta_data_by_context=HashWithIndifferentAccess.new
    all('ul.contexts li').each do |context|
      context.find('a').click()
      Rails.logger.info ['changing metadata for context', context[:'data-context-id']]
      change_and_remember_the_value_of_each_visible_meta_data_field
      @meta_data_by_context[context[:'data-context-id']] = @meta_data
    end

    click_on_text 'Speichern'
    wait_for_ajax

    expect(current_path).to be== media_entry_path(@media_entry)

    every_meta_data_value_is_visible_on_the_page

    click_on_button 'Metadaten editieren'

    each_meta_data_value_in_each_context_is_equal_to_the_one_set_previously

  end

  scenario 'Adding a new person as the author', browser: :headless do

    visit_edit_page_of_user_first_media_entry
    delete_all_existing_authors

    click_on_the_fieldset_icon 'author'

    fill_in 'last_name', with: 'Turner'
    fill_in 'first_name', with: 'William'
    fill_in 'pseudonym', with: 'Willi'

    click_on_text 'Person einfügen'
    assert_multi_select_tag 'Turner, William (Willi)'

    click_on_text 'Speichern'
    wait_for_ajax
    assert_page_of_user_first_media_entry
    expect(page).to have_content 'Turner, William (Willi)'

  end

  scenario 'Adding a new group as the author', browser: :headless do

    visit_edit_page_of_user_first_media_entry
    delete_all_existing_authors

    click_on_the_fieldset_icon 'author'
    click_on_text 'Gruppe'
    fill_in 'first_name', with: 'El Grupo [Gruppe]'
    click_on_text 'Gruppe einfügen'
    assert_multi_select_tag 'El Grupo [Gruppe]'

    click_on_text 'Speichern'
    assert_page_of_user_first_media_entry
    expect(page).to have_content 'El Grupo [Gruppe]'

  end

  scenario 'License: selecting an individual license clears presets', browser: :firefox do

    visit_edit_page_of_user_first_media_entry

    click_on_text 'Credits'
    click_on_text 'Weitere Angaben'

    find('select.copyright-roots').select 'Public Domain'
    assert_textarea_within_fieldset_not_empty 'copyright usage'
    assert_textarea_within_fieldset_not_empty 'copyright url'

    find('select.copyright-roots').select 'individuelle Lizenz'
    assert_textarea_within_fieldset_is_empty 'copyright usage'
    assert_textarea_within_fieldset_is_empty 'copyright url'

    # when leaving page, one has to confirm
    visit root_path
    accept_alert_dialog

  end

  scenario 'License: selecting a child of a license', browser: :headless do

    visit_edit_page_of_user_first_media_entry

    click_on_text 'Credits'
    click_on_text 'Weitere Angaben'

    find('select.copyright-roots').select 'Urheberrechtlich geschützt (standardisierte Lizenz)'
    find('select.copyright-children').select 'CC-By-CH: Attribution'

    click_on_text 'Speichern'
    wait_for_ajax
    expect(page).to have_content 'C-By-CH: Attribution'

  end

  scenario 'License: editing license shows current (sub) selection', browser: :headless do

    visit_edit_page_of_user_first_media_entry

    click_on_text 'Credits'
    click_on_text 'Weitere Angaben'

    find('select.copyright-roots').select 'Urheberrechtlich geschützt (standardisierte Lizenz)'
    find('select.copyright-children').select 'CC-By-CH: Attribution'

    click_on_text 'Speichern'

    visit_edit_page_of_user_first_media_entry
    click_on_text 'Credits'
    click_on_text 'Weitere Angaben'
    assert_selected_option 'select.copyright-children', 'CC-By-CH: Attribution'

  end

  scenario 'Show warning before leaving media entry edit page and losing unsaved data', browser: :firefox do

    visit_edit_page_of_user_first_media_entry

    change_value_of_some_input_field

    # try to leave the page
    accept_alert do
      find('.ui-header-brand a').click
    end
    assert_change_of_current_path

  end

  scenario 'Show warning before leaving media entry multiple edit page (batch) and losing unsaved data', browser: :firefox do

    edit_multiple_media_entries_using_the_batch

    change_value_of_some_input_field

    # try to leave the page

    accept_alert do
      find('.ui-header-brand a').click
    end
    assert_change_of_current_path

  end

  #
  # Logging and Debugging
  # 
  before :each do
    @meta_data_by_context=HashWithIndifferentAccess.new
    @meta_data= []
    @current_field_set= nil
    @current_index= nil
  end

  after :each do |example|
    if example.exception != nil
      Rails.logger.error "meta_data_by_context: #{@meta_data_by_context.to_yaml}"
      Rails.logger.error "meta_data: \n #{@meta_data.to_yaml}"
      Rails.logger.error "current_type: \n #{@current_type}"
      Rails.logger.error "current_meta_key: \n #{@current_meta_key}"
      Rails.logger.error "current_index: \n #{@current_index}"
      Rails.logger.error "current_field_set: \n #{@current_field_set}"
      @current_meta_datum = @meta_data[(@current_index or 0)]
      Rails.logger.error "current_meta_datum: \n#{@current_meta_datum}"
    end
  end

end
