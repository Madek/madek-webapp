require 'rails_helper'
require 'spec_helper_feature_shared'
require Rails.root.join('spec', 'features', 'meta_data', 'shared.rb')

feature 'MetaData' do
  include Features::MetaData::Shared

  scenario 'Show warning before leaving media entry edit page and losing unsaved data', browser: :firefox do
    @current_user = sign_in_as 'normin'

    visit_edit_page_of_user_first_media_entry
    hide_clipboard

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


end
