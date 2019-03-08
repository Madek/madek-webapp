require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/batch_selection_helper'
include BatchSelectionHelper

require_relative './shared/batch_shared_dropdown_spec'

require_relative '../shared/context_meta_data_helper_spec'
include ContextMetaDataHelper

feature 'batch remove meta data' do

  scenario 'remove for media entries' do
    user = create_user

    resource_1 = create_media_entry('Media Entry 1', user)
    resource_2 = create_media_entry('Media Entry 2', user)

    execute_scenario(user, resource_1, resource_2)
  end

  scenario 'remove for collections' do
    user = create_user

    resource_1 = create_collection('Collection 1', user)
    resource_2 = create_collection('Collection 2', user)

    execute_scenario(user, resource_1, resource_2)
  end

  private

  def execute_scenario(user, resource_1, resource_2)
    app_setting = AppSetting.first
    app_setting.contexts_for_entry_validation = ['core']

    app_setting.save!
    app_setting.reload

    set_keywords(resource_1, ['abc', 'def', 'ghi'])
    set_keywords(resource_2, ['def', 'jkl'])

    all_resources = [resource_1, resource_2]

    parent = create_collection('Parent', user)
    add_all_to_parent(all_resources, parent)

    login(user)
    visit_resource(parent)

    meta_data_count_before = MetaDatum.all.count

    click_dropdown
    action = "#{resource_1.class.name.underscore.pluralize}_edit_all".to_sym
    click_batch_action(action)

    check_no_meta_data_dropdown(
      resource_1.class, 'madek_core', 'madek_core:title')

    select_meta_data_batch_action(
      resource_1.class,
      'madek_core',
      'madek_core:keywords',
      I18n.t(:meta_data_batch_action_remove_meta_data))

    click_save
    check_success_flash

    meta_data_count_after = MetaDatum.all.count

    expect(meta_data_count_before - meta_data_count_after).to eq(2)

    expect(resource_keywords(resource_1).length).to eq(0)
    expect(resource_keywords(resource_2).length).to eq(0)
  end
  # rubocop:enable Metrics/MethodLength

  def click_save
    find('.tab-content').find('.ui-actions')
      .find('button', text: I18n.t('meta_data_form_save')).click
  end

  def resource_keywords(resource)
    resource.meta_data.where(meta_key_id: 'madek_core:keywords')
  end

  def check_success_flash
    find('.ui-alert.success')
  end

  def select_meta_data_batch_action(clazz, context_id, meta_key_id, action)
    fieldset = find_context_meta_key_form_by_id(context_id, meta_key_id)
    select = fieldset.find(
      meta_data_dropdown_selector_within_fieldset(clazz, meta_key_id)
    )
    select.select action
  end

  def check_no_meta_data_dropdown(clazz, context_id, meta_key_id)
    fieldset = find_context_meta_key_form_by_id(context_id, meta_key_id)
    within fieldset do
      expect(page).to have_no_selector(
        meta_data_dropdown_selector_within_fieldset(clazz, meta_key_id)
      )
    end
  end

  def meta_data_dropdown_selector_within_fieldset(clazz, meta_key_id)
    name = "#{clazz.name.underscore}[meta_data][#{meta_key_id}][batch_action]"
    "select[name='#{name}']"
  end

  def set_keywords(resource, keyword_list)
    keywords = keyword_list.map do |keyword|
      result = Keyword.find_by(term: keyword)
      if result
        result
      else
        FactoryGirl.create(
          :keyword,
          term: keyword,
          meta_key: meta_key('madek_core:keywords'))
      end
    end

    FactoryGirl.create(
      :meta_datum_keywords,
      keywords: keywords,
      resource.class.name.underscore => resource,
      meta_key: meta_key('madek_core:keywords'))

    resource.reload
  end

  def meta_key(type)
    MetaKey.find_by(id: type)
  end
end
