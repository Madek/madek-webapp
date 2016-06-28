require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

module ContextMetaDataHelper

  def update_context_text_field(key, value)
    meta_key = MetaKey.find(key)
    find_context_meta_key_form(meta_key)
      .find('input')
      .set(value)
  end

  def clear_context_text_field(key)
    meta_key = MetaKey.find(key)
    input = find_context_meta_key_form(meta_key)
      .find('input')
    input.click
    input.native.send_keys(:backspace) until input.value.empty?
  end

  def read_context_text_field(key)
    meta_key = MetaKey.find(key)
    find_context_meta_key_form(meta_key)
      .find('input').value
  end

  def update_context_bubble_no_js(key, value)
    meta_key = MetaKey.find(key)
    find_context_meta_key_form(meta_key)
      .find('.form-item-add input')
      .set(value.id)
  end

  def read_context_bubble_no_js(key)
    meta_key = MetaKey.find(key)
    find_context_meta_key_form(meta_key)
      .find('.form-item-add input')
      .value
  end

  def update_context_checkbox(key, value)
    meta_key = MetaKey.find(key)
    find_context_meta_key_form(meta_key)
      .find(:xpath, './/input[@value="' + value.id + '"]')
      .click
  end

  def read_context_checkbox(key, value)
    meta_key = MetaKey.find(key)
    find_context_meta_key_form(meta_key)
      .find(:xpath, './/input[@value="' + value.id + '"]')
      .checked?
  end

  def update_context_bubble(key, value)
    meta_key = MetaKey.find(key)

    val = if meta_key.meta_datum_object_type == 'MetaDatum::Groups'
      value.name
    else
      value.term
    end
    autocomplete_and_choose_first(
      find_context_meta_key_form(meta_key),
      val)
  end

  def find_context_meta_key_form(meta_key)
    xpath = './/fieldset[.//.[@class="form-label"]'
    xpath += '[contains(.,"' + meta_key.label + '")]]'
    find(:xpath, xpath)
  end

  def edit_context_path(context)
    underscored = @resource.class.name.underscore
    variable = 'edit_context_meta_data_' + underscored + '_path'
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
    xpath = './/.[@class="ui-tabs-item"][.//.[contains(.,"' + label + '")]]'
    find(:xpath, xpath).find('a').click
    if async
      expect(current_path).to eq(path_before)
    else
      expect(current_path).to eq(edit_context_path(context))
    end
  end
end
