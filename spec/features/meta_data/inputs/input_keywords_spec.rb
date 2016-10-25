require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: MetaDatum' do
  background do
    @user = User.find_by(login: 'normin')
    sign_in_as @user.login
    @media_entry = FactoryGirl.create :media_entry_with_image_media_file,
                                      creator: @user, responsible_user: @user

  end

  context 'Keywords' do

    example 'autocomplete shows empty results message' do
      meta_key = create_meta_key_keywords
      in_the_edit_field(meta_key.label) do
        fill_autocomplete('xxxxxxxxxxxxxxxxxxx')
        expect(
          find(
            '.tt-dataset-KeywordsSearch div',
            text: I18n.t('app_autocomplete_no_results'))
        ).to be
      end
    end

    example 'autocomplete styles existing values' do
      meta_key = create_meta_key_keywords
      100.times { FactoryGirl.create(:keyword, meta_key: meta_key) }
      meta_datum = FactoryGirl.create(
        :meta_datum_keywords, meta_key: meta_key, media_entry: @media_entry)
      existing_term = meta_datum.keywords.sample.term

      in_the_edit_field(meta_key.label) do
        fill_autocomplete(existing_term)
        expect(
          find('.ui-autocomplete-disabled', text: existing_term)
        ).to be
      end
    end

  end

  private

  # create a metakey and set it as the only input field:
  def create_meta_key_keywords
    meta_key = FactoryGirl.create(:meta_key_keywords)
    context_key = FactoryGirl.create(:context_key, meta_key: meta_key, label: nil)
    AppSettings.first.update_attributes!(
      contexts_for_entry_edit: [context_key.context_id],
      context_for_entry_summary: context_key.context_id)

    meta_key
  end

  def in_the_edit_field(label, &block)
    visit edit_context_meta_data_media_entry_path(@media_entry)
    within('form .ui-form-group', text: label, &block)
  end

  def fill_autocomplete(text)
    input = find('input')
    input.click
    input.set(text)
    input.click
  end

end
