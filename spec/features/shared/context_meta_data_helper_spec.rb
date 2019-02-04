require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

module ContextMetaDataHelper

  def find_context_text_field(context_id, meta_key_id)
    find_context_meta_key_form_by_id(context_id, meta_key_id)
      .find('input, textarea')
  end

  def update_context_text_field(context_id, meta_key_id, value)
    find_context_text_field(context_id, meta_key_id)
      .set(value)
  end

  def clear_context_text_field(context_id, meta_key_id)
    input = find_context_text_field(context_id, meta_key_id)
    input.click
    input.native.send_keys(:backspace) until input.value.empty?
  end

  def read_context_text_field(context_id, meta_key_id)
    find_context_text_field(context_id, meta_key_id)
      .value
  end

  def update_context_bubble(context_id, meta_key_id, value)
    element = find_context_meta_key_form_by_id(context_id, meta_key_id)
    autocomplete_and_choose_first(element, value)
  end

  def update_context_bubble_no_js(context_id, meta_key_id, value)
    find_context_meta_key_form_by_id(context_id, meta_key_id)
      .find('.form-item-add input')
      .set(value.id)
  end

  def update_context_roles_field(context_id, meta_key_id, value, full: false)
    open_context(context_id, true) unless full

    form = find_context_meta_key_form_by_id(context_id, meta_key_id)
    autocomplete_and_choose_first(form, value, press_escape: true)

    random_role = MetaKey.find(meta_key_id).roles.map(&:label).sample

    within form do
      form.find('table a', text: 'Add a role').click
      select random_role, from: 'role_id'
      click_button I18n.t(:meta_data_input_person_save)
    end
  end

  def clean_context_roles_field(context_id, meta_key_id, full: false)
    open_context(context_id, true) unless full

    fieldset = find_context_meta_key_form_by_id(context_id, meta_key_id)
    until fieldset.all('.form-item table tr td:last-child a').empty?
      fieldset.all('.form-item table tr td:last-child a').first.click
    end
  end

  def read_context_bubble_no_js(context_id, meta_key_id)
    find_context_meta_key_form_by_id(context_id, meta_key_id)
      .find('.form-item-add input')
      .value
  end

  def update_context_checkbox(context_id, meta_key_id, value)
    find_context_meta_key_form_by_id(context_id, meta_key_id)
      .find(:xpath, './/input[@value="' + value.id + '"]')
      .click
  end

  def read_context_checkbox(context_id, meta_key_id, value)
    find_context_meta_key_form_by_id(context_id, meta_key_id)
      .find(:xpath, './/input[@value="' + value.id + '"]')
      .checked?
  end

  def get_label(context_id, meta_key_id)
    context_keys = ContextKey.where(
      meta_key_id: meta_key_id,
      context_id: context_id)

    expect(context_keys.length).to be < 2

    if context_keys.empty?
      MetaKey.find(meta_key_id).label
    else
      context_key = context_keys[0]
      if context_key.label && context_key.label != ''
        context_key.label
      else
        MetaKey.find(meta_key_id).label
      end
    end
  end

  def find_context_meta_key_form_by_id(context_id, meta_key_id)
    find_context_meta_key_form(get_label(context_id, meta_key_id))
  end

  def find_context_meta_key_form(label)
    xpath = './/fieldset[.//.[@class="form-label"]'
    xpath += '[contains(.,"' + label + '")]]'
    find(:xpath, xpath)
  end

  def edit_context_path(context)
    underscored = @resource.class.name.underscore
    variable = 'edit_meta_data_by_context_' + underscored + '_path'
    if context
      send(variable, @resource, context)
    else
      send(variable, @resource)
    end
  end

  def open_full_or_context(config, async)
    if config[:full]
      open_full
    else
      open_context(config[:context], async)
    end
  end

  def open_context(context, async)
    path_before = current_path
    label = Context.find(context).label
    find('.ui-tabs-item', text: label).click
    if async
      expect(current_path).to eq(path_before)
    else
      expect(current_path).to eq(edit_context_path(context))
    end
  end
end
