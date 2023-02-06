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

    create_media_entry_with_meta_datum_keywords(
      'Title 1', 'vocabulary_a', 'keyword_aa', true, true)
    create_media_entry_with_meta_datum_keywords(
      'Title 2', 'vocabulary_a', 'keyword_ab', false, false)
    create_media_entry_with_meta_datum_keywords(
      'Title 3', 'vocabulary_a', 'keyword_ac', true, true)
    create_media_entry_with_meta_datum_text(
      'Title 4', 'vocabulary_a', 'text_ag', true, false)
    create_media_entry('Title 5', true, true)

    visit_vocabulary_contents(vocabulary)

    check_title(vocabulary.label)
    check_tabs(
      [
        { key: :vocabularies_tabs_vocabulary, active: false },
        { key: :vocabularies_tabs_keywords, active: false },
        { key: :vocabularies_tabs_contents, active: true },
        { key: :vocabularies_tabs_permissions, active: false }
      ]
    )
    check_media_entries(['Title 1', 'Title 3'])
  end

  private

  def check_media_entries(titles)
    within('.ui-polybox') do
      expect(page).to have_selector(
        '.ui-thumbnail-meta-title', count: titles.length)

      titles.each do |title|
        expect(page).to have_selector(
          '.ui-thumbnail-meta-title', text: title)
      end
    end
  end

  def visit_vocabulary_contents(vocabulary)
    visit vocabulary_contents_path(vocabulary)
  end

  def create_media_entry(title, published, viewable)
    media_entry = FactoryBot.create(:media_entry)
    if published
      title_key = MetaKey.find('madek_core:title')
      rights_key = MetaKey.find('madek_core:copyright_notice')
      FactoryBot.create(
        :meta_datum_text,
        meta_key: title_key,
        media_entry: media_entry,
        string: title)
      FactoryBot.create(
        :meta_datum_text,
        meta_key: rights_key,
        media_entry: media_entry)
    end
    media_entry.is_published = published
    media_entry.get_metadata_and_previews = viewable
    media_entry.save
    media_entry.reload
  end

  def create_media_entry_with_meta_datum_keywords(
    title, vocabulary_id, meta_key_id, published, viewable)
    media_entry = create_media_entry(title, published, viewable)
    meta_key_id = vocabulary_id + ':' + meta_key_id
    meta_key = MetaKey.find(meta_key_id)
    FactoryBot.create(
      :meta_datum_keywords,
      meta_key: meta_key,
      media_entry: media_entry)
  end

  def create_media_entry_with_meta_datum_text(
    title, vocabulary_id, meta_key_id, published, viewable)
    media_entry = create_media_entry(title, published, viewable)
    meta_key_id = vocabulary_id + ':' + meta_key_id
    meta_key = MetaKey.find(meta_key_id)
    FactoryBot.create(
      :meta_datum_text,
      meta_key: meta_key,
      media_entry: media_entry)
  end

  def create_vocabulary(vocabulary_id, keyword_ids, other_ids)
    vocabulary = FactoryBot.create(:vocabulary, id: vocabulary_id)

    keyword_meta_keys = keyword_ids.map do |index|
      FactoryBot.create(:meta_key_keywords, id: vocabulary_id + ':' + index)
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
