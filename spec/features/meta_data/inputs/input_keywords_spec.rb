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

  context 'Different keyword selection types (include saving)' do
    context "Multiple selection" do
      example 'field type = "auto": show checkboxes when n <= 16' do
        meta_key = create_meta_key_keywords()
        expect(meta_key.multiple_selection).to eq(true) # make sure multiple selection is on by default
        expect(meta_key.selection_field_type).to eq("auto") # make sure field type is auto by default
        16.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }
        k1, k2 = meta_key.keywords.sample 2
        in_the_edit_field(meta_key.label) do
          expect(page).to have_selector('input[type=checkbox]', count: 16)
          check(k1.term)
          check(k2.term)
        end
        click_on('Speichern')
        expect(page).to have_selector('.ui-tag-cloud-item', text: k1.term)
        expect(page).to have_selector('.ui-tag-cloud-item', text: k2.term)
      end

      example 'field type = "auto": show autocomplete when n > 16' do
        meta_key = create_meta_key_keywords()
        17.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }
        k1, k2 = meta_key.keywords.sample 2
        in_the_edit_field(meta_key.label) do
          expect(page).to have_selector('.ui-autocomplete-holder', count: 1)
          autocomplete_and_choose_first(page, k1.term)
          autocomplete_and_choose_first(page, k2.term, press_escape: true)
        end
        click_on('Speichern')
        expect(page).to have_selector('.ui-tag-cloud-item', text: k1.term)
        expect(page).to have_selector('.ui-tag-cloud-item', text: k2.term)
      end

      example 'field type = "list": show autocomplete even when n <= 16' do
        meta_key = create_meta_key_keywords(selection_field_type: "list")
        16.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }
        k1, k2 = meta_key.keywords.sample 2
        in_the_edit_field(meta_key.label) do
          expect(page).to have_selector('.ui-autocomplete-holder', count: 1)
          autocomplete_and_choose_first(page, k1.term)
          autocomplete_and_choose_first(page, k2.term, press_escape: true)
        end
        click_on('Speichern')
        expect(page).to have_selector('.ui-tag-cloud-item', text: k1.term)
        expect(page).to have_selector('.ui-tag-cloud-item', text: k2.term)
      end

      example 'field type = "mark": show checkboxes even when n > 16' do
        meta_key = create_meta_key_keywords(selection_field_type: "mark")
        17.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }
        k1, k2 = meta_key.keywords.sample 2
        in_the_edit_field(meta_key.label) do
          expect(page).to have_selector('input[type=checkbox]', count: 17)
          check(k1.term)
          check(k2.term)
        end
        click_on('Speichern')
        expect(page).to have_selector('.ui-tag-cloud-item', text: k1.term)
        expect(page).to have_selector('.ui-tag-cloud-item', text: k2.term)
      end

      example 'extensible list forces autocomplete even when field type is "mark"' do
        meta_key = create_meta_key_keywords(selection_field_type: "mark", is_extensible_list: true)
        16.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }
        in_the_edit_field(meta_key.label) do
          expect(page).to have_selector('.ui-autocomplete-holder', count: 1)
          find('input').click
          expect(page).to have_selector('.tt-selectable', count: 16)
        end
      end
    end

    context 'Single selection' do
      example 'field type = "auto": show radio buttons when n <= 16' do
        meta_key = create_meta_key_keywords(multiple_selection: false)
        16.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }
        k1 = meta_key.keywords.sample
        in_the_edit_field(meta_key.label) do
          expect(page).to have_selector('input[type=radio]', count: 16)
          choose(k1.term)
        end
        click_on('Speichern')
        expect(page).to have_selector('.ui-tag-cloud-item', text: k1.term)
      end

      example 'field type = "auto": show autocomplete when n > 16' do
        meta_key = create_meta_key_keywords(multiple_selection: false)
        17.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }
        k1 = meta_key.keywords.sample
        in_the_edit_field(meta_key.label) do
          expect(page).to have_selector('.ui-autocomplete-holder', count: 1)
          expect(page).to have_selector('.multi-select-input')
          autocomplete_and_choose_first(page, k1.term)
          expect(page).not_to have_selector('.multi-select-input') # because it is restricted to single selection
        end
        click_on('Speichern')
        expect(page).to have_selector('.ui-tag-cloud-item', text: k1.term)
      end

      example 'field type = "list": show autocomplete even when n <= 16' do
        meta_key = create_meta_key_keywords(multiple_selection: false, selection_field_type: "list")
        16.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }
        k1 = meta_key.keywords.sample
        in_the_edit_field(meta_key.label) do
          expect(page).to have_selector('.ui-autocomplete-holder', count: 1)
          expect(page).to have_selector('.multi-select-input')
          autocomplete_and_choose_first(page, k1.term)
          expect(page).not_to have_selector('.multi-select-input') # because it is restricted to single selection
        end
        click_on('Speichern')
        expect(page).to have_selector('.ui-tag-cloud-item', text: k1.term)
      end

      example 'field type = "mark": show radio buttons even when n > 16' do
        meta_key = create_meta_key_keywords(multiple_selection: false, selection_field_type: "mark")
        17.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }
        k1 = meta_key.keywords.sample
        in_the_edit_field(meta_key.label) do
          expect(page).to have_selector('input[type=radio]', count: 17)
          choose(k1.term)
        end
        click_on('Speichern')
        expect(page).to have_selector('.ui-tag-cloud-item', text: k1.term)
      end

      example 'extensible list forces autocomplete even when field type is "mark"' do
        meta_key = create_meta_key_keywords(multiple_selection: false, selection_field_type: "mark", is_extensible_list: true)
        16.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }
        in_the_edit_field(meta_key.label) do
          expect(page).to have_selector('.ui-autocomplete-holder', count: 1)
          find('input').click
          expect(page).to have_selector('.tt-selectable', count: 16)
        end
      end
    end

    context 'with silent server errors' do
      before do
        # Workaround for this issue: https://github.com/Madek/Madek/issues/688
        # Otherwise the unhandled exception bubbles to the top and raises
        # AFTER the actual spec.
        Capybara.raise_server_errors = false
      end
      after do
        Capybara.raise_server_errors = true
      end
      example 'server throws when selecting multiple for single select field' do
        meta_key = create_meta_key_keywords(multiple_selection: true)
        16.times.map { FactoryBot.create(:keyword, meta_key: meta_key) }
        k1, k2 = meta_key.keywords.sample 2
        in_the_edit_field(meta_key.label) do
          check(k1.term)
          check(k2.term)
        end
        meta_key.multiple_selection = false
        meta_key.save!
        click_on 'Speichern'
        expect(page).to have_content 'System error'
        expect(page).not_to have_selector('.ui-tag-cloud-item', text: k1.term)
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
