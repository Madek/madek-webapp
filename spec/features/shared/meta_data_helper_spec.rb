require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

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

  def create_or_find_group(name)
    group = Group.find_by(name: name)
    if group
      group
    else
      FactoryGirl.create(
        :group,
        name: name)
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
    element = meta_key.text_type == 'line' ? 'input' : 'textarea'
    find_meta_key_form(meta_key)
      .find(element)
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
    autocomplete_and_choose_first(find_meta_key_form(meta_key), value)
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

  def prepare_manipulate_and_check(config, prepare, manipulate, check)
    prepare.call

    login_and_edit
    open_full_or_context(config, config[:async])

    within('.tab-content') do
      manipulate.call
      submit_form
    end

    expect(current_path).to eq resource_path
    @resource.reload

    check.call
  end

  def resource_path
    underscored = @resource.class.name.underscore
    send (underscored + '_path'), @resource
  end

  def check_context_url(context_id)
    expect(current_path).to eq(edit_context_path(context_id))
  end

  def check_selected_tab(context_id)
    label_context_id =
      if context_id
        context_id
      else
        'core'
      end
    expected_label = Context.find(label_context_id).label
    within('.app-body') do
      find('li.active.ui-tabs-item').find('a', text: expected_label)
    end
    check_context_url(context_id)
  end

  def login_and_edit
    login
    visit resource_path
    click_action_button('pen')
    expect(current_path).to eq edit_context_path(nil)
  end

  def open_full
    find('.ui-tabs-item', text: I18n.t(:meta_data_form_all_data)).click
  end
end
