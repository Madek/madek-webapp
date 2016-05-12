require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative 'shared/basic_data_helper_spec'
require_relative 'shared/meta_data_helper_spec'
include BasicDataHelper
include MetaDataHelper

feature 'Resource: Collection' do
  describe 'Concern: MetaData' do

    it 'update via Edit-Form (Javascript disabled)', browser: :firefox do
      prepare_data
      login

      visit collection_path(@resource)

      click_action_button('pen')

      expect(current_path).to eq edit_meta_data_collection_path(@resource)

      within('form[name="resource_meta_data"]') do
        update_text_field('madek_core:title', 'New Title')
        update_text_field('madek_core:description', '')
        update_bubble('madek_core:keywords', @keyword)
        update_text_field('media_set:uploaded_at', '01.01.2016')
        submit_form
      end

      expect(current_path).to eq collection_path(@resource)
      @resource.reload

      expect(find_datum(@resource, 'madek_core:title').string).to eq 'New Title'
      expect(find_datum(@resource, 'madek_core:description')).to eq nil
      expect(find_datum(@resource, 'madek_core:keywords').try(:keywords))
        .to include(@keyword)
      expect(find_datum(@resource, 'media_set:uploaded_at').string)
        .to eq '01.01.2016'
    end
  end

  def prepare_data
    prepare_user
    @keyword = create_or_find_keyword('Test Keyword')
    @resource = create_collection('Test Collection')
  end
end
