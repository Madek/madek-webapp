require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './shared/basic_data_helper_spec'
include BasicDataHelper

feature 'Vocabulary keywords' do

  scenario 'Check if shown' do

    vocabulary = create_vocabulary(
      'vocabulary_a',
      %w(keyword_aa keyword_ab keyword_ac keyword_ad keyword_ae),
      %w(text_ag text_ah))

    visit_madek_core_vocabulary(vocabulary)

    check_title(vocabulary.label)
    check_tabs(
      [
        { key: :vocabularies_tabs_vocabulary, active: false },
        { key: :vocabularies_tabs_keywords, active: true }
      ]
    )
    check_meta_keys(
      vocabulary,
      %w(keyword_aa keyword_ab keyword_ac keyword_ad keyword_ae))
  end

  scenario 'Check vocabulary invisible for public' do
    vocabulary = create_vocabulary('vocabulary_a', %w(keyword_aa), %w(text_ag))
    vocabulary.enabled_for_public_view = false
    vocabulary.save

    visit_madek_core_vocabulary(vocabulary)
    expect(page).to have_content 'Error 401'
  end

  scenario 'Check vocabulary invisible for user' do
    prepare_user
    vocabulary = create_vocabulary('vocabulary_a', %w(keyword_aa), %w(text_ag))
    vocabulary.enabled_for_public_view = false
    vocabulary.save

    login

    visit_madek_core_vocabulary(vocabulary)
    expect(page).to have_content 'Error 403'
  end

  scenario 'Check vocabulary visible for user' do
    prepare_user
    vocabulary = create_vocabulary('vocabulary_a', %w(keyword_aa), %w(text_ag))
    vocabulary.enabled_for_public_view = false
    vocabulary.save

    FactoryGirl.create(
      :vocabulary_user_permission,
      user: @user,
      vocabulary: vocabulary,
      view: true)

    login

    visit_madek_core_vocabulary(vocabulary)

    check_title(vocabulary.label)
    check_tabs(
      [
        { key: :vocabularies_tabs_vocabulary, active: false },
        { key: :vocabularies_tabs_keywords, active: true }
      ]
    )
    check_meta_keys(
      vocabulary,
      %w(keyword_aa keyword_ab keyword_ac keyword_ad keyword_ae))
  end

  private

  def check_meta_keys(vocabulary, meta_key_ids)
    concat_ids = meta_key_ids.map do |meta_key_id|
      vocabulary.id + ':' + meta_key_id
    end

    meta_keys = vocabulary.meta_keys.where(id: concat_ids)
    expect(page).to have_selector('.ui-metadata-box', count: meta_keys.length)

    meta_keys.each do |meta_key|
      expect(page).to have_selector('.ui-metadata-box', text: meta_key.label)
    end
  end

  def check_title(title)
    find('.ui-body-title-label', text: title)
  end

  def check_tabs(tabs)
    within('.app-body-ui-container') do

      tabs.each do |tab|
        element = find('.ui-tabs-item', text: I18n.t(tab[:key]))

        if tab[:active]
          element.assert_matches_selector('[class*=active]')
        else
          element.assert_not_matches_selector('[class*=active]')
        end
      end
    end
  end

  def visit_madek_core_vocabulary(vocabulary)
    visit vocabulary_keywords_path(vocabulary)
  end

  def create_vocabulary(vocabulary_id, keyword_ids, other_ids)
    vocabulary = FactoryGirl.create(:vocabulary, id: vocabulary_id)

    keyword_meta_keys = keyword_ids.map do |index|
      FactoryGirl.create(:meta_key_keywords, id: vocabulary_id + ':' + index)
    end

    other_meta_keys = other_ids.map do |index|
      FactoryGirl.create(:meta_key_text, id: vocabulary_id + ':' + index)
    end

    keyword_meta_keys.concat(other_meta_keys).each do |meta_key|
      vocabulary.meta_keys << meta_key
    end

    vocabulary
  end
end
