require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './_shared'
include MetaDatumInputsHelper

feature 'Resource: MetaDatum' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
    @media_entry = FactoryGirl.create :media_entry_with_image_media_file,
                                      creator: @user, responsible_user: @user
  end

  context 'MetaDatum::Text' do
    background do
      @vocabulary = FactoryGirl.create(:vocabulary)
      @meta_key = FactoryGirl.create(:meta_key_text)
      @context_key = FactoryGirl.create(:context_key, meta_key: @meta_key)
      configure_as_only_input(@context_key)
    end

    example 'add new text (single line)' do
      # NOTE: this also tests the whitespace trimming:
      TEST_STRING_LINE_IN = "  Hello World\n  \n  ".freeze
      TEST_STRING_LINE_OUT = 'Hello World'.freeze

      edit_in_meta_data_form_and_save do
        expect(input = find('input[type="text"]')).to be
        expect(input.value).to eq ''
        input.set(TEST_STRING_LINE_IN)
      end

      expect_meta_datum_on_detail_view(TEST_STRING_LINE_OUT)
    end

    example 'add new text (block/textarea)' do

      pending 'not implemented/broken'

      # NOTE: this also tests the whitespace trimming:
      TEST_STRING_BLOCK_IN = "  Hello World\nWelcome to the World of tomorrow! \n "
                                .freeze
      TEST_STRING_BLOCK_OUT = "Hello World\nWelcome to the World of tomorrow!"
                                .freeze

      @context_key.update_attributes!(text_element: :textarea)
      edit_in_meta_data_form_and_save do
        expect(input = find('textarea')).to be
        expect(input.value).to eq ''
        input.set(TEST_STRING_BLOCK_IN)
      end

      expect_meta_datum_on_detail_view(TEST_STRING_BLOCK_OUT)
    end

  end
end
