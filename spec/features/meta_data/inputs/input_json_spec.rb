require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './_shared'
include MetaDatumInputsHelper

feature 'Resource: MetaDatum' do
  background do
    @user = User.find_by(login: 'normin')
    @media_entry =
      FactoryGirl.create :media_entry_with_image_media_file, creator: @user, responsible_user: @user
  end

  context 'MetaDatum::JSON' do
    background do
      @vocabulary = FactoryGirl.create(:vocabulary)
      @meta_key = FactoryGirl.create(:meta_key_json)
      @context_key = FactoryGirl.create(:context_key, meta_key: @meta_key)
      configure_as_only_input(@context_key)
    end

    example 'add new JSON as text' do
      # NOTE: has custom whitespace we make sure to keep intact
      TEST_DATA_IN = "\n  { \"someObject\"   : \n{  \"key\"   : \"value\"      }   } \n ".freeze
      # NOTE: after beeing saved as JSON, its shown pretty-printed
      TEST_DATA_OUT = "{\n  \"someObject\": {\n    \"key\": \"value\"\n  }\n}".freeze
      # NOTE: and when Rails gets the value from the DB it is already parsed as an Object
      TEST_DATA_SAVED = { 'someObject' => { 'key' => 'value' } }.freeze

      edit_in_meta_data_form_and_save do
        expect(input = find('textarea')).to be
        expect(input.value).to eq ''
        input.set(TEST_DATA_IN)
        expect(input[:value]).to eq TEST_DATA_IN
      end

      # Check that the rendered HTML contains line breaks.
      expect(
        find('.ui-media-overview-metadata').find('.media-data-content li textarea')[:innerHTML]
      ).to eq(TEST_DATA_OUT)

      # Check that the saved value has the right format.
      expect(@media_entry.meta_data.find_by(meta_key_id: @context_key.meta_key_id).json).to eq(
        TEST_DATA_SAVED
      )
    end

    context 'show warning when the JSON text error' do
      context 'warns on syntactic error' do
        examples = [
          {
            name: 'unquoted',
            in: "\n{ \"someObject\": { \"key\": unquoted} }",
            msg:
              'Eingabefehler: unexpected character at line 2 ' \
                'column 26 of the JSON data'
          },
          {
            name: 'not closed',
            in: "\n{ \"not closed\": { }",
            msg:
              'Eingabefehler: end of data after property value in ' \
                'object at line 2 column 20 of the JSON data'
          }
        ].freeze

        examples.each do |example|
          example(example[:name]) do
            edit_in_meta_data_form do
              expect(input = find('textarea')).to be
              expect(input.value).to eq ''
              input.set(example[:in])
              expect(find('p.ui-alert.error').text).to eq example[:msg]
            end
          end
        end
      end

      # it 'warns on semantic error' do
      #   TEST_DATA_IN = '"1337"'.freeze
      # end
    end
  end
end
