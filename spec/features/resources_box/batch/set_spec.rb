require_relative '../resources_box_helper_spec'
include ResourcesBoxHelper

require_relative '../../shared/batch_selection_helper'
include BatchSelectionHelper

require_relative '../../shared/context_meta_data_helper_spec'
include ContextMetaDataHelper

feature 'set batch' do

  scenario 'mixed view all entries' do
    config = create_data(create_config)
    login_new(config)

    visit_parent(config, 'all')
    do_batch_update(21, MediaEntry, 'Shared Title')

    check_titles_changed(config, all_media_entry_syms, 'Shared Title')
    check_titles_unchanged(config, all_collection_syms)
  end

  scenario 'mixed view all sets' do
    config = create_data(create_config)
    login_new(config)

    visit_parent(config, 'all')
    do_batch_update(21, Collection, 'Shared Title')

    check_titles_unchanged(config, all_media_entry_syms)
    check_titles_changed(config, all_collection_syms, 'Shared Title')
  end

  scenario 'entry view all entries' do
    config = create_data(create_config)
    login_new(config)

    visit_parent(config, 'entries')
    do_batch_update(21, MediaEntry, 'Shared Title')

    check_titles_changed(config, all_media_entry_syms, 'Shared Title')
    check_titles_unchanged(config, all_collection_syms)
  end

  scenario 'set view all sets' do
    config = create_data(create_config)
    login_new(config)

    visit_parent(config, 'collections')
    do_batch_update(21, Collection, 'Shared Title')

    check_titles_unchanged(config, all_media_entry_syms)
    check_titles_changed(config, all_collection_syms, 'Shared Title')
  end

  private

  def check_titles_changed(config, ids, title)
    ids.each do |id|
      resource = resource_by_id(config, id)
      expect(resource.reload.title).to eq(title)
    end
  end

  def check_titles_unchanged(config, ids)
    ids.each do |id|
      entry = entry_by_id(config, id)
      resource = entry[:resource]
      expect(resource.reload.title).to eq(entry[:title])
    end
  end

  def do_batch_update(count, type, title)
    plural = type.name.underscore.pluralize
    click_dropdown
    click_batch_action("#{plural}_metadata".to_sym, all: true)
    check_batch_edit(count, type)
    change_title(title)
    click_save
    check_success(count, type)
  end

  def check_success(count, type)
    if type == MediaEntry
      text = \
        I18n.t(:meta_data_batch_summary_all_pre) \
        + count.to_s \
        + I18n.t(:meta_data_batch_summary_all_post)
    elsif type == Collection
      text = \
        I18n.t(:meta_data_collection_batch_summary_all_pre) \
        + count.to_s \
        + I18n.t(:meta_data_collection_batch_summary_all_post)
    else
      throw 'Unexpected type: ' + type
    end
    find('.ui-alert', text: text)
  end

  def change_title(title)
    update_context_text_field('core', 'madek_core:title', title)
  end

  def click_save
    find('.tab-content').find('.ui-actions')
      .find('button', text: I18n.t('meta_data_form_save')).click
  end

  def check_batch_edit(count, type)
    plural = type.name.underscore.pluralize
    title =
      I18n.t(:meta_data_batch_title_pre) \
      + count.to_s \
      + I18n.t("meta_data_batch_title_post_#{plural}".to_sym)
    find('.ui-body-title-label', text: title)
  end

  def visit_parent(config, type)
    parent = resource_by_id(config, :parent)
    visit_resource(
      parent,
      type: type
    )
  end

  def all_media_entry_syms
    [*100..120].map { |i| "media_entry_#{i}".to_sym }
  end

  def all_collection_syms
    [*100..120].map { |i| "collection_#{i}".to_sym }
  end

  # rubocop:disable Metrics/MethodLength
  def create_config
    [
      {
        type: User
      }
    ] \
    + [*100..120].map do |i|
      {
        type: MediaEntry,
        id: "media_entry_#{i}".to_sym,
        title: "#{i} Media Entry",
        created_at: i,
        last_change: i
      }
    end \
    + [*100..120].map do |i|
      {
        type: Collection,
        id: "collection_#{i}".to_sym,
        title: "#{i} Collection",
        created_at: i,
        last_change: i
      }
    end \
    + [
      {
        type: Collection,
        id: :parent,
        title: 'Parent',
        created_at: 0,
        last_change: 0,
        children: all_media_entry_syms + all_collection_syms
      }
    ]
  end
  # rubocop:enable Metrics/MethodLength
end
