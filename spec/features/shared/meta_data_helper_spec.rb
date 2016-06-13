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

  def create_or_find_person(pseudonym)
    person = Person.find_by(pseudonym: pseudonym)
    if person
      person
    else
      FactoryGirl.create(
        :person,
        pseudonym: pseudonym)
    end
  end

  def add_authors_datum(resource, people)
    FactoryGirl.create(
      :meta_datum_people,
      people: people,
      meta_key: MetaKey.find_by(id: 'madek_core:authors'),
      media_entry: resource)
  end

  def add_creators_datum(resource, creators)
    FactoryGirl.create(
      :meta_datum_people,
      people: creators,
      meta_key: MetaKey.find_by(id: 'media_object:creator'),
      media_entry: resource)
  end

  def update_text_field(key, value)
    meta_key = MetaKey.find(key)
    find_meta_key_form(meta_key)
      .find('input')
      .set(value)
  end

  def update_context_text_field(key, value)
    meta_key = MetaKey.find(key)
    find_context_meta_key_form(meta_key)
      .find('input')
      .set(value)
  end

  def update_bubble_no_js(key, value)
    meta_key = MetaKey.find(key)
    find_meta_key_form(meta_key)
      .find('.form-item-add input')
      .set(value.id)
  end

  def update_context_bubble_no_js(key, value)
    meta_key = MetaKey.find(key)
    find_context_meta_key_form(meta_key)
      .find('.form-item-add input')
      .set(value.id)
  end

  def update_bubble(key, value)
    meta_key = MetaKey.find(key)
    autocomplete_and_choose_first(find_meta_key_form(meta_key), value.term)
  end

  def update_context_bubble(key, value)
    meta_key = MetaKey.find(key)
    autocomplete_and_choose_first(
      find_context_meta_key_form(meta_key),
      value.term)
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

  def find_context_meta_key_form(meta_key)
    xpath = './/fieldset[.//.[@class="form-label"]'
    xpath += '[contains(.,"' + meta_key.label + '")]]'
    find(:xpath, xpath)
  end

  def prepare_manipulate_and_check(config, prepare, manipulate, check)
    prepare.call

    underscored = @resource.class.name.underscore

    resource_path = send (underscored + '_path'), @resource
    edit_context_path = send(
      ('edit_context_meta_data_' + underscored + '_path'), @resource)

    login
    visit resource_path
    click_action_button('pen')
    expect(current_path).to eq edit_context_path
    open_full_or_context(config, edit_context_path, config[:async])

    within('form[name="resource_meta_data"]') do
      manipulate.call
      submit_form
    end

    expect(current_path).to eq resource_path
    @resource.reload

    check.call
  end

  def open_full_or_context(config, edit_context_path, async)
    underscored = @resource.class.name.underscore
    edit_path = send ('edit_meta_data_' + underscored + '_path'), @resource
    if config[:full]
      click_action_button('arrow-down')
      expect(current_path).to eq edit_path
    else
      label = Context.find(config[:context]).label
      xpath = './/.[@class="ui-tabs-item"][.//.[contains(.,"' + label + '")]]'
      find(:xpath, xpath).find('a').click
      if async
        expect(current_path).to eq(edit_context_path)
      else
        expect(current_path).to eq(edit_context_path + '/' + config[:context])
      end
    end
  end
end
