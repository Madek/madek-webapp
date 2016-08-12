require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: MetaDatum' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
    @media_entry = FactoryGirl.create :media_entry_with_image_media_file,
                                      creator: @user, responsible_user: @user

    # this key always exists; in personas it is used in 'summary context'
    meta_key = MetaKey.find 'madek_core:title'
    @meta_datum = FactoryGirl.create(
      :meta_datum_text,
      meta_key: meta_key,
      media_entry: @media_entry)
    @context_key = Context
      .find(AppSettings.first.context_for_entry_summary)
      .context_keys.where(meta_key_id: meta_key.id).first
    @summmary_box = '.ui-resource-overview .ui-metadata-box'
  end

  describe 'Action: Update' do

  pending \
    'update MetaDatum::Text from it\'s detail view with Javascript disabled',
    browser: :firefox_nojs do

    scenario 'single update' do
      new_text = Faker::Lorem.words.join(' ')

      visit media_entry_path(@media_entry)

      click_on @context_key.label

      click_on I18n.t(:meta_data_action_edit_btn)

      within("form[action='#{meta_datum_path(@meta_datum)}']") do
        find('input[type="text"]').set(new_text)
        submit_form
      end

      expect(find('.app-body')).to have_content new_text
    end
  end

  context \
    'inline edit MetaDatum::Text from MediaEntry detail view' do

    pending 'single update' do
      new_text = Faker::Lorem.words.join(' ')

      visit media_entry_path(@media_entry)

      within(@summmary_box) do

        within("[data-meta-datum-url=\"#{meta_datum_path(@meta_datum)}\"]") do
          find('a').click
          find('input').set(new_text)
          submit_form
          # wait for xhr to finish:
          find('[data-meta-datum-persisted]', text: new_text)
        end

      end

      expect(@meta_datum.reload.string).to eq new_text
    end
  end
  end
end
