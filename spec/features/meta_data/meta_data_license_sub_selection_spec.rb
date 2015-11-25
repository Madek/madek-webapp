require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'meta_data', 'shared.rb')

feature 'MetaData' do
  include Features::MetaData::Shared

  scenario 'License: editing license shows current (sub) selection', browser: :headless do
    @current_user = sign_in_as 'normin'

    visit_edit_page_of_user_first_media_entry
    hide_clipboard

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
