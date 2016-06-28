require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

require_relative '../shared/meta_data_helper_spec'
include MetaDataHelper

require_relative '../shared/context_meta_data_helper_spec'
include ContextMetaDataHelper

feature 'Resource: Collection' do
  describe 'Concern: MetaData' do

    it 'edit full form with-js', browser: :firefox do

      prepare_manipulate_and_check(
        {
          full: true,
          context: nil,
          async: true
        },
        lambda do
          prepare_data
        end,
        lambda do
          update_text_field('madek_core:title', 'New Title')
          update_text_field('madek_core:description', '')
          update_bubble('madek_core:keywords', @keyword)
          update_text_field('media_set:uploaded_at', '01.01.2016')
        end,
        lambda do
          expect(find_datum(@resource, 'madek_core:title').string)
            .to eq 'New Title'
          expect(find_datum(@resource, 'madek_core:description')).to eq nil
          expect(find_datum(@resource, 'madek_core:keywords').try(:keywords))
            .to include(@keyword)
          expect(find_datum(@resource, 'media_set:uploaded_at').string)
            .to eq '01.01.2016'
        end
      )

    end

    it 'edit context form with-js', browser: :firefox do

      prepare_manipulate_and_check(
        {
          full: false,
          context: 'media_content',
          async: true
        },
        lambda do
          prepare_data
        end,
        lambda do
          update_context_text_field('madek_core:title', 'New Title')
          update_context_text_field('madek_core:description', '')
          update_context_bubble('madek_core:keywords', @keyword)
        end,
        lambda do
          expect(find_datum(@resource, 'madek_core:title').string)
            .to eq 'New Title'
          expect(find_datum(@resource, 'madek_core:description')).to eq nil
          expect(find_datum(@resource, 'madek_core:keywords').try(:keywords))
            .to include(@keyword)
          expect(find_datum(@resource, 'media_set:uploaded_at'))
            .to eq nil
        end
      )

    end

  end

  def prepare_data
    prepare_user
    @keyword = create_or_find_keyword('Test Keyword')
    @resource = create_collection('Test Collection')
  end
end
