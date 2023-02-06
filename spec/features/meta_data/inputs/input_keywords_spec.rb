require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './_shared'
include MetaDatumInputsHelper

feature 'Resource: MetaDatum' do
  background do
    @user = User.find_by(login: 'normin')
    @media_entry = FactoryBot.create :media_entry_with_image_media_file,
                                      creator: @user, responsible_user: @user

  end

  context 'Keywords' do

    example 'autocomplete shows empty results message' do
      meta_key = create_meta_key_keywords(is_extensible_list: true)
      in_the_edit_field(meta_key.label) do
        fill_autocomplete('xxxxxxxxxxxxxxxxxxx')
        expect(
          find(
            '.tt-dataset-KeywordsSearch div',
            text: I18n.t('app_autocomplete_no_results'))
        ).to be
      end
    end

    example 'autocomplete prefills values' do
      meta_key = create_meta_key_keywords(is_extensible_list: false)
      24.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }
      existing_terms = meta_key.keywords.map(&:term) # order from model

      in_the_edit_field(meta_key.label) do
        find('input')
          .click
        expect(
          find('.ui-autocomplete.tt-open').all('.tt-selectable').map(&:text)
        ).to eq existing_terms
      end
    end

    example 'autocomplete styles existing values' do
      meta_key = create_meta_key_keywords(is_extensible_list: true)
      100.times { FactoryBot.create(:keyword, meta_key: meta_key) }
      meta_datum = FactoryBot.create(
        :meta_datum_keywords, meta_key: meta_key, media_entry: @media_entry)
      existing_term = meta_datum.keywords.sample.term

      in_the_edit_field(meta_key.label) do
        fill_autocomplete(existing_term)
        expect(
          find('.ui-autocomplete-disabled', text: existing_term)
        ).to be
      end
    end

    example 'autocomplete (prefilled) styles existing values' do
      meta_key = create_meta_key_keywords(is_extensible_list: false)
      24.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }
      meta_datum = FactoryBot.create(
        :meta_datum_keywords, meta_key: meta_key, media_entry: @media_entry)
      existing_term = meta_datum.keywords.sample.term

      in_the_edit_field(meta_key.label) do
        fill_autocomplete(existing_term)
        expect(
          find('.ui-autocomplete-disabled', text: existing_term)
        ).to be
      end
    end

    example 'show checkboxes if not extensible and n <= 16' do
      meta_key = create_meta_key_keywords(is_extensible_list: false)
      16.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }

      in_the_edit_field(meta_key.label) do
        expect(page).to have_selector('input[type=checkbox]', count: 16)
      end
    end

    example 'show autocomplete n prefilled if not extensible and n > 16' do
      meta_key = create_meta_key_keywords(is_extensible_list: false)
      24.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }

      in_the_edit_field(meta_key.label) do
        expect(page).to have_selector('.ui-autocomplete-holder', count: 1)
        find('input').click
        expect(page).to have_selector('.tt-selectable', count: 24)
      end
    end

    example 'show autocomplete 50 prefilled if not extensible and n > 50' do
      meta_key = create_meta_key_keywords(is_extensible_list: false)
      70.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }
      in_the_edit_field(meta_key.label) do
        expect(page).to have_selector('.ui-autocomplete-holder', count: 1)
        find('input').click
        expect(page).to have_selector('.tt-selectable', count: 50)
      end
    end

    example 'show autocomplete n prefilled if extensible and n > 16' do
      meta_key = create_meta_key_keywords(is_extensible_list: true)
      24.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }

      in_the_edit_field(meta_key.label) do
        expect(page).to have_selector('.ui-autocomplete-holder', count: 1)
        find('input').click
        expect(page).to have_selector('.tt-selectable', count: 24)
      end
    end

    example 'show autocomplete 50 prefilled if extensible and n > 50' do
      meta_key = create_meta_key_keywords(is_extensible_list: true)
      70.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }
      in_the_edit_field(meta_key.label) do
        expect(page).to have_selector('.ui-autocomplete-holder', count: 1)
        find('input').click
        expect(page).to have_selector('.tt-selectable', count: 50)
      end
    end

    example 'show nothing if not extensible and n == 0' do
      meta_key = create_meta_key_keywords(is_extensible_list: false)

      in_the_edit_field(meta_key.label) do
        expect(page).to have_selector('input', count: 0)
      end
    end
  end

  private

  # create a metakey and set it as the only input field:
  def create_meta_key_keywords(attrs = {})
    meta_key = FactoryBot.create(:meta_key_keywords, **attrs)
    context_key = FactoryBot.create(
      :context_key,
      meta_key: meta_key,
      labels: { de: nil })
    configure_as_only_input(context_key)
    meta_key
  end

  def in_the_edit_field(label, &block)
    visit edit_meta_data_by_context_media_entry_path(@media_entry)
    sign_in_as @user.login
    within('form .ui-form-group', text: label, &block)
  end

  def fill_autocomplete(text)
    input = find('input')
    input.click
    input.set(text)
    input.click
  end

end
