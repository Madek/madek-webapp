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
        { key: :vocabularies_tabs_contents, active: false },
        { key: :vocabularies_tabs_permissions, active: false }
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
    expect(page).to have_content I18n.t(:error_401_title)
  end

  scenario 'Check vocabulary invisible for user' do
    prepare_user
    vocabulary = create_vocabulary('vocabulary_a', %w(keyword_aa), %w(text_ag))
    vocabulary.enabled_for_public_view = false
    vocabulary.save

    login

    visit_vocabulary_keywords(vocabulary)
    expect(page).to have_content I18n.t(:error_403_title)
  end

  scenario 'Check vocabulary visible for user' do
    prepare_user
    vocabulary = create_vocabulary('vocabulary_a', %w(keyword_aa), %w(text_ag))
    vocabulary.enabled_for_public_view = false
    vocabulary.save

    FactoryBot.create(
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
        { key: :vocabularies_tabs_contents, active: false },
        { key: :vocabularies_tabs_permissions, active: false }
      ]
    )
    check_meta_keys(
      vocabulary,
      %w(keyword_aa keyword_ab keyword_ac keyword_ad keyword_ae))
  end

  scenario 'Check keywords tab enabled if empty but visited by path' do
    prepare_user
    vocabulary = create_vocabulary('vocabulary', [], [])
    visit_vocabulary_keywords(vocabulary)
    check_tabs(
      [
        { key: :vocabularies_tabs_vocabulary, active: false },
        { key: :vocabularies_tabs_keywords, active: true },
        { key: :vocabularies_tabs_contents, active: false },
        { key: :vocabularies_tabs_permissions, active: false }
      ]
    )
  end

  scenario 'Check keywords tab disabled if empty' do
    prepare_user
    vocabulary = create_vocabulary('vocabulary', [], [])
    visit_vocabulary_show(vocabulary)
    check_tabs(
      [
        { key: :vocabularies_tabs_vocabulary, active: true },
        { key: :vocabularies_tabs_contents, active: false },
        { key: :vocabularies_tabs_permissions, active: false }
      ]
    )
  end

  scenario 'Check keywords content for keywords key' do
    prepare_user
    vocabulary = create_vocabulary('vocabulary', ['keyword'], [])

    media_entry = FactoryBot.create(:media_entry)
    meta_datum = FactoryBot.create(
      :meta_datum_keywords,
      meta_key_id: 'vocabulary:keyword')
    media_entry.meta_data << meta_datum

    visit_vocabulary_keywords(vocabulary)
    check_keyword_content(
      'vocabulary',
      'keyword',
      meta_datum.keywords.map(&:term)
    )
  end

  scenario 'Check message if no keywords in key' do
    prepare_user
    vocabulary = create_vocabulary('vocabulary', ['keyword'], [])
    visit_vocabulary_keywords(vocabulary)
    check_no_keyword_content('vocabulary', 'keyword')
  end

  private

  def check_keyword_content(vocabulary_id, keyword_id, keyword_terms)
    meta_key = Vocabulary.find(vocabulary_id).meta_keys.where(
      id: vocabulary_id + ':' + keyword_id).first
    box = find('.ui-metadata-box', text: meta_key.label)

    expect(box).to have_selector(
      '.ui-tag-cloud-item',
      count: keyword_terms.length)

    keyword_terms.each do |keyword_term|
      box.find('.ui-tag-cloud-item', text: keyword_term)
    end
  end

  def check_no_keyword_content(vocabulary_id, keyword_id)
    meta_key = Vocabulary.find(vocabulary_id).meta_keys.where(
      id: vocabulary_id + ':' + keyword_id).first
    box = find('.ui-metadata-box', text: meta_key.label)
    box.find('div', text: I18n.t(:vocabularies_no_keywords))
  end

  def check_meta_keys(vocabulary, meta_key_ids)
    concat_ids = meta_key_ids.map do |meta_key_id|
      vocabulary.id + ':' + meta_key_id
    end

    meta_keys = vocabulary.meta_keys.where(id: concat_ids)
    expect(page).to have_selector('.ui-metadata-box', count: meta_keys.length)

    meta_keys.each do |meta_key|
      expect(page).to have_selector('.ui-metadata-box', text: meta_key.label)
      label = if meta_key.keywords_alphabetical_order
        I18n.t(:meta_key_order_alphabetical)
      else
        I18n.t(:meta_key_order_custom)
      end
      expect(find('h3.title-s-alt', text: meta_key.label).find('small').text)
        .to include(label)
    end
  end

  def visit_vocabulary_keywords(vocabulary)
    visit vocabulary_keywords_path(vocabulary)
  end

  def visit_vocabulary_show(vocabulary)
    visit vocabulary_path(vocabulary)
  end

  def create_vocabulary(vocabulary_id, keyword_ids, other_ids)
    vocabulary = FactoryBot.create(:vocabulary, id: vocabulary_id)

    keyword_meta_keys = keyword_ids.map do |index|
      FactoryBot.create(
        :meta_key_keywords,
        id: vocabulary_id + ':' + index,
        keywords_alphabetical_order: [true, false].sample)
    end

    other_meta_keys = other_ids.map do |index|
      FactoryBot.create(:meta_key_text, id: vocabulary_id + ':' + index)
    end

    keyword_meta_keys.concat(other_meta_keys).each do |meta_key|
      vocabulary.meta_keys << meta_key
    end

    vocabulary
  end
end
