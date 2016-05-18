require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative 'ui_helpers_spec'
include UIHelpers

module MetaDataHelper

  def create_or_find_keyword(term)
    keyword = Keyword.find_by(term: term)
    if keyword
      keyword
    else
      FactoryGirl.create(
        :keyword,
        term: term,
        meta_key: MetaKey.find_by(id: 'madek_core:keywords'))
    end
  end

  def update_text_field(key, value)
    meta_key = MetaKey.find(key)
    find_meta_key_form(meta_key)
      .find('input')
      .set(value)
  end

  def update_bubble_no_js(key, value)
    meta_key = MetaKey.find(key)
    find_meta_key_form(meta_key)
      .find('.form-item-add input')
      .set(value.id)
  end

  def update_bubble(key, value)
    meta_key = MetaKey.find(key)
    autocomplete_and_choose_first(find_meta_key_form(meta_key), value.term)
  end

  def find_datum(resource, meta_key)
    resource.reload.meta_data.find_by(meta_key: meta_key)
  end

  def find_vocabulary_form(name)
    find('h3', text: name).find(:xpath, '../..')
  end

  def find_meta_key_form(meta_key)
    find_vocabulary_form(meta_key.vocabulary.label)
      .find('.form-label', text: meta_key.label).find(:xpath, '..')
  end

end
