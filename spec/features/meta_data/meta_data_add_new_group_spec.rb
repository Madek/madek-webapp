require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'meta_data', 'shared.rb')

feature 'MetaData' do
  include Features::MetaData::Shared

  scenario 'Adding a new group as the author', browser: :headless do
    @current_user = sign_in_as 'normin'

    visit_edit_page_of_user_first_media_entry
    hide_clipboard
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
