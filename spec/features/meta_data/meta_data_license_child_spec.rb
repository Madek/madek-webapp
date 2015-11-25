require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'meta_data', 'shared.rb')

feature 'MetaData' do
  include Features::MetaData::Shared

  scenario 'License: selecting a child of a license', browser: :headless do
    @current_user = sign_in_as 'normin'

    visit_edit_page_of_user_first_media_entry
    hide_clipboard

    click_on_text 'Credits'
    click_on_text 'Weitere Angaben'

    find('select.copyright-roots').select 'Urheberrechtlich geschützt (standardisierte Lizenz)'
    find('select.copyright-children').select 'CC-By-CH: Attribution'

    click_on_text 'Speichern'
    wait_for_ajax
    expect(page).to have_content 'C-By-CH: Attribution'

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
