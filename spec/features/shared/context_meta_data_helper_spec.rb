require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

module ContextMetaDataHelper

  def update_context_text_field(context_id, meta_key_id, value)
    find_context_meta_key_form_by_id(context_id, meta_key_id)
      .find('input')
      .set(value)
  end

  def clear_context_text_field(context_id, meta_key_id)
    input = find_context_meta_key_form_by_id(context_id, meta_key_id)
      .find('input')
    input.click
    input.native.send_keys(:backspace) until input.value.empty?
  end

  def read_context_text_field(context_id, meta_key_id)
    find_context_meta_key_form_by_id(context_id, meta_key_id)
      .find('input').value
  end

  def update_context_bubble_no_js(context_id, meta_key_id, value)
    find_context_meta_key_form_by_id(context_id, meta_key_id)
      .find('.form-item-add input')
      .set(value.id)
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
