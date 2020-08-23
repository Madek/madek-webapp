require 'spec_helper'
require 'spec_helper_feature'

require_relative './_shared'
include MetaDatumInputsHelper

feature 'Resource: MetaDatum' do
  background do
    @user = User.find_by(login: 'normin')
    @media_entry = create(:media_entry_with_image_media_file,
                          creator: @user, responsible_user: @user)
    @context_key = ContextKey.find_by!(meta_key_id: 'madek_core:copyright_notice')
  end

  context 'MetaDatum::Text' do
    context 'madek_core:copyright_notice' do
      background do
        AppSetting.first.update!(
          copyright_notice_default_text: 'Default Text',
          copyright_notice_templates: ['foo', 'bar', 'xoxo']
        )
      end

      context 'when default text is specified' do
        context 'when templates are specified' do
          scenario 'displaying them as suggestions' do
            edit_in_meta_data_form_and_save do
              find('input[name]').click

              expect(
                find('.ui-autocomplete.tt-open').all('.tt-selectable').map(&:text)
              ).to eq ['Default Text', 'foo', 'bar', 'xoxo']
            end
          end

          scenario 'Selecting a suggestion' do
            edit_in_meta_data_form_and_save do
              input = find('input[name]')

              input.click
              input.native.send_keys(:arrow_down)
              input.native.send_keys(:arrow_down)
              input.native.send_keys(:enter)

              expect(input.value).to eq('foo')
            end

            expect(page).to have_content 'Rechte foo'
          end
        end

        context 'when there are no templates' do
          background { AppSetting.first.update!(copyright_notice_templates: []) }

          scenario 'displaying default text as suggestion only' do
            edit_in_meta_data_form_and_save do
              find('input[name]').click

              expect(
                find('.ui-autocomplete.tt-open .tt-selectable').text
              ).to eq 'Default Text'
            end
          end
        end
      end

      context 'when default text is empty' do
        background do
          AppSetting.first.update!(copyright_notice_default_text: nil)
        end

        context 'when templates are specified' do
          scenario 'displaying them as suggestions' do
            edit_in_meta_data_form_and_save do
              find('input[name]').click

              expect(
                find('.ui-autocomplete.tt-open').all('.tt-selectable').map(&:text)
              ).to eq ['foo', 'bar', 'xoxo']
            end
          end
        end

        context 'when there are no templates' do
          background { AppSetting.first.update!(copyright_notice_templates: []) }

          scenario 'Displaying no suggestions' do
            edit_in_meta_data_form_and_save do
              input = find('input[name]')
              input.click

              expect(page).to have_no_css('.ui-autocomplete')
              input.set('custom copyright value')
            end

            expect(page).to have_content 'Rechte custom copyright value'
          end
        end
      end
    end
  end
end
