require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './_shared'
include MetaDatumInputsHelper

feature 'Resource: MetaDatum' do
  given(:description) { Faker::Lorem.sentence }

  background do
    @user = User.find_by(login: 'normin')
    @media_entry = create(:media_entry_with_image_media_file,
                          creator: @user,
                          responsible_user: @user)
    @other_media_entry = create(
      :media_entry_with_image_media_file, responsible_user: @user)
  end

  context 'MetaDatum::MediaEntry' do
    background do
      @vocabulary = create(:vocabulary)
      @meta_key = create(:meta_key_media_entry)
      @context_key = create(:context_key, meta_key: @meta_key)
      configure_as_only_input(@context_key)
    end

    scenario 'add new valid ID with description' do
      valid_id = @other_media_entry.id

      edit_in_meta_data_form_and_save do
        hidden_input = find('input[type="hidden"]', visible: :hidden)
        inputs = all('input[type="text"]')
        expect(inputs.count).to be 2
        input = inputs.first
        textarea = inputs.last

        expect(hidden_input.value).to eq(';')
        expect(input.value).to eq('')
        expect(textarea.value).to eq('')
        expect(page).not_to have_css 'p.ui-alert'

        input.set(valid_id)
        textarea.set(description)
        expect(input.value).to eq(valid_id)
        expect(page).not_to have_css 'p.ui-alert'
        expect(textarea.value).to eq(description)
        expect(hidden_input.value).to eq("#{valid_id};#{description}")
      end

      within '.ui-media-overview-metadata .media-data-content' do
        title = @other_media_entry.title
        href = media_entry_path(@other_media_entry)
        expect(page).to have_link(title, href: href)
        expect(page).to have_content(description)
      end
    end

    context 'when invalid ID is passed' do
      given(:invalid_id) { @other_media_entry.id + '_invalid' }

      scenario 'display alert with error message' do
        edit_in_meta_data_form_and_save do
          inputs = all('input[type="text"]')
          expect(inputs.count).to be 2
          input = inputs.first

          input.set(invalid_id)
          expect(page).to have_css 'p.ui-alert'
        end
      end

      pending 'throws error when saving' do
        edit_in_meta_data_form_and_save do
          hidden_input = find('input[type="hidden"]', visible: :hidden)
          inputs = all('input[type="text"]')
          expect(inputs.count).to be 2
          input = inputs.first
          textarea = inputs.last

          input.set(invalid_id)
          textarea.set(description)
          expect(hidden_input.value).to eq("#{invalid_id};#{description}")
        end

        within '.ui-media-overview-metadata .media-data-content' do
          title = @other_media_entry.title
          href = media_entry_path(@other_media_entry)
          expect(page).to have_no_link(title, href: href)
          expect(page).to have_content(description)
        end

        edit_in_meta_data_form do
          hidden_input = find('input[type="hidden"]', visible: :hidden)
          inputs = all('input[type="text"]')
          expect(inputs.count).to be 2
          input = inputs.first

          expect(hidden_input.value).to eq(";#{description}")
          expect(input.value).to eq('')
          expect(textarea.value).to eq(description)
        end
      end
    end

    describe 'deletion' do
      background do
        @media_entry.meta_data << create(:meta_datum_media_entry,
                                         other_media_entry: @other_media_entry,
                                         string: description)
      end

      context 'when empty ID is passed' do
        context 'when description is left untouched' do
          scenario 'delete the meta data' do
            edit_in_meta_data_form_and_save do
              expect(uuid_input.value).to eq(@other_media_entry.id)
              expect(description_input.value).to eq(description)
              expect(hidden_input.value).to eq("#{@other_media_entry.id};#{description}")

              uuid_input.set('')
              expect(hidden_input.value).to eq(";#{description}")
            end

            expect(page).not_to have_css('.ui-media-overview-metadata .media-data-content')
            expect(page).not_to have_link(@other_media_entry.title,
                                          href: media_entry_path(@other_media_entry))
            expect(page).not_to have_content(description)
            expect(@media_entry.meta_data.find_by(type: 'MetaDatum::MediaEntry')).not_to be
          end
        end

        context 'when description is set to empty' do
          scenario 'delete the meta data' do
            edit_in_meta_data_form_and_save do
              expect(uuid_input.value).to eq(@other_media_entry.id)
              expect(description_input.value).to eq(description)
              expect(hidden_input.value).to eq("#{@other_media_entry.id};#{description}")

              uuid_input.set('')
              description_input.set('')
              expect(hidden_input.value).to eq(';')
            end

            expect(page).not_to have_css('.ui-media-overview-metadata .media-data-content')
            expect(page).not_to have_link(@other_media_entry.title,
                                          href: media_entry_path(@other_media_entry))
            expect(page).not_to have_content(description)
            expect(@media_entry.meta_data.find_by(type: 'MetaDatum::MediaEntry')).not_to be
          end
        end
      end
    end
  end
end

def hidden_input
  find('input[type="hidden"]', visible: :hidden)
end

def uuid_input
  all('input[type="text"]').first
end

def description_input
  all('input[type="text"]').last
end
