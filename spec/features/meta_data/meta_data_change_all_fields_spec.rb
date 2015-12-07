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

  scenario 'Changing all meta-data fields of a media entry', browser: :firefox do

    pending 'broken, see https://github.com/zhdk/madek/blob/master/spec/README.md'

    @current_user = sign_in_as 'normin'

    @media_entry = FactoryGirl.create :media_entry_with_image_media_file, user: @current_user
    visit media_entry_path(@media_entry)
    click_on_button 'Metadaten editieren'

    # change the value of each meta-data field of each context
    hide_clipboard
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
    hide_clipboard

    each_meta_data_value_in_each_context_is_equal_to_the_one_set_previously

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
      binding.pry

      Rails.logger.error "meta_data_by_context: #{@meta_data_by_context.to_yaml}"
      Rails.logger.error "meta_data: \n #{@meta_data.to_yaml}"
      Rails.logger.error "current_type: \n #{@current_type}"
      Rails.logger.error "current_meta_key: \n #{@current_meta_key}"
      Rails.logger.error "current_index: \n #{@current_index}"
      Rails.logger.error "current_field_set: \n #{@current_field_set}"
      @current_meta_datum = @meta_data[(@current_index or 0)] unless @meta_data.nil?
      Rails.logger.error "current_meta_datum: \n#{@current_meta_datum}" if current_meta_datum
    end
  end

end
