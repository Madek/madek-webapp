require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

require_relative '../shared/vocabulary_shared'
include VocabularyShared

feature 'Vocabulary keywords' do

  scenario 'Check if shown' do

    vocabulary = create_vocabulary(
      'vocabulary_a',
      %w(keyword_aa keyword_ab keyword_ac keyword_ad keyword_ae),
      %w(text_ag text_ah))

    visit_vocabulary_keywords(vocabulary)

    check_title(vocabulary.label)
    check_tabs(
      [
        { key: :vocabularies_tabs_vocabulary, active: false },
        { key: :vocabularies_tabs_keywords, active: true },
        { key: :vocabularies_tabs_contents, active: false }
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

    visit_vocabulary_keywords(vocabulary)
    expect(page).to have_content 'Error 401'
  end

  scenario 'Check vocabulary invisible for user' do
    prepare_user
    vocabulary = create_vocabulary('vocabulary_a', %w(keyword_aa), %w(text_ag))
    vocabulary.enabled_for_public_view = false
    vocabulary.save

    login

    visit_vocabulary_keywords(vocabulary)
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

    visit_vocabulary_keywords(vocabulary)

    check_title(vocabulary.label)
    check_tabs(
      [
        { key: :vocabularies_tabs_vocabulary, active: false },
        { key: :vocabularies_tabs_keywords, active: true },
        { key: :vocabularies_tabs_contents, active: false }
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

  def visit_vocabulary_keywords(vocabulary)
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
