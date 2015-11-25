require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'meta_data', 'shared.rb')

feature 'MetaData' do
  include Features::MetaData::Shared

  scenario 'Adding a new person as the author', browser: :headless do
    @current_user = sign_in_as 'normin'

    visit_edit_page_of_user_first_media_entry
    hide_clipboard
    delete_all_existing_authors

    click_on_the_fieldset_icon 'author'

    fill_in 'last_name', with: 'Turner'
    fill_in 'first_name', with: 'William'
    fill_in 'pseudonym', with: 'Willi'

    click_on_text 'Person einfügen'
    assert_multi_select_tag 'Turner, William (Willi)'

    click_on_text 'Speichern'
    wait_for_ajax
    hide_clipboard
    assert_page_of_user_first_media_entry
    expect(page).to have_content 'Turner, William (Willi)'

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


end
