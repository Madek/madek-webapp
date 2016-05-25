require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/meta_data_helper_spec'
include MetaDataHelper

require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

doc = <<-DOC
Action: Updating

"Create", "Add Value", "Modify Value" and "Delete" Metadata

Tested variations :
1. a. MD::Text exists, value is present: update MD
1. b. MD::People exists, value is present: update MD
2. MD exists, value is empty: delete MD
3. MD does not exist, value is present: create MD
4. MD does not exist, value is empty: ignore/skip

(MD="A MetaDatum for this MetaKey on this Resource")
DOC

feature 'Resource: MediaEntry' do
  describe 'Concern: MetaData' do

    describe doc do

      scenario 'update via Javascript Models (unit test)', browser: :firefox do

        prepare_data
        login

        config = {
          entry: media_entry_path(@resource),
          meta_key_id: 'madek_core:title',
          values: ['New Title']
        }

        # changes the configured key to value and saves to server:
        # response is a forward url or errors
        response = js_integration_test 'MediaEntryMetaData', config
        expect(response['body']['forward_url'])
          .to eq media_entry_path(@resource)

        # expect the change to reflected in db
        expect(find_datum(@resource, config[:meta_key_id]).string)
          .to eq 'New Title'
      end

      it 'edit full form no-js', browser: :firefox_nojs do

        prepare_manipulate_and_check(
          {
            full: true,
            context: nil
          },
          lambda do
            prepare_data
          end,
          lambda do
            update_text_field('madek_core:title', 'New Title')
            update_bubble_no_js('madek_core:authors', @co_author)
            update_text_field('madek_core:description', '')
            update_bubble_no_js('media_object:creator', @creator)
          end,
          lambda do
            expect(find_datum(@resource, 'madek_core:title').string)
              .to eq 'New Title'
            expect(find_datum(@resource, 'madek_core:authors').try(:people))
              .to include(@author)
            expect(find_datum(@resource, 'madek_core:authors').try(:people))
              .to include(@co_author)
            expect(find_datum(@resource, 'madek_core:authors')
              .try(:people).length).to eq(2)
            expect(find_datum(@resource, 'madek_core:description')).to eq nil
            expect(find_datum(@resource, 'media_object:creator').try(:people))
              .to eq([@creator])
            expect(find_datum(@resource, 'madek_core:portrayed_object_date'))
              .to eq nil
          end
        )
      end

      it 'edit context form no-js', browser: :firefox_nojs do

        prepare_manipulate_and_check(
          {
            full: false,
            context: 'media_content'
          },
          lambda do
            prepare_data
          end,
          lambda do
            update_context_text_field('madek_core:title', 'New Title')
            update_context_bubble_no_js('madek_core:authors', @co_author)
            update_context_text_field('madek_core:description', '')
          end,
          lambda do
            expect(find_datum(@resource, 'madek_core:title').string)
              .to eq 'New Title'
            expect(find_datum(@resource, 'madek_core:authors').try(:people))
              .to include(@author)
            expect(find_datum(@resource, 'madek_core:authors').try(:people))
              .to include(@co_author)
            expect(find_datum(@resource, 'madek_core:authors')
              .try(:people).length).to eq(2)
            expect(find_datum(@resource, 'madek_core:description')).to eq nil
            expect(find_datum(@resource, 'madek_core:portrayed_object_date'))
              .to eq nil
          end
        )
      end

    end
  end
end

def prepare_data
  prepare_user
  @resource = create_media_entry('Test Media Entry')
  @author = create_or_find_person('Author')
  @co_author = create_or_find_person('Co-Author')
  @creator = create_or_find_person('Creator')

  add_authors_datum(@resource, [@author])
  expect(find_datum(@resource, 'madek_core:authors').people.length).to eq 1

  add_creators_datum(@resource, [])

  @resource.reload
end
