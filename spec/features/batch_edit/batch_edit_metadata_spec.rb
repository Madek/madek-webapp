require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/favorite_helper_spec'
require_relative '../shared/basic_data_helper_spec'
include FavoriteHelper
include BasicDataHelper

require_relative '../shared/batch_selection_helper'
include BatchSelectionHelper

require_relative '../shared/context_meta_data_helper_spec'
include ContextMetaDataHelper

feature 'Batch edit metadata' do

  scenario 'Ignore resources of wrong type' do
    prepare_and_login

    visit_batch(MediaEntry, mixed_1_3_1_3)
    check_thumbnail_count(media_entries_1_3)
    check_thumbnail_count_by_type(MediaEntry, media_entries_1_3)
    check_thumbnail_count_by_type(Collection, [])
    check_thumbnail_titles(media_entries_1_3)

    visit_batch(Collection, mixed_1_3_1_3)
    check_thumbnail_count(collections_1_3)
    check_thumbnail_count_by_type(MediaEntry, [])
    check_thumbnail_count_by_type(Collection, collections_1_3)
    check_thumbnail_titles(collections_1_3)
  end

  scenario 'Update media entries title' do
    prepare_and_login
    visit_batch(MediaEntry, mixed_1_3_1_3)

    update_context_text_field('core', 'madek_core:title', 'Shared Title')
    click_save
    wait_until { current_path == my_dashboard_path }

    check_resource_title(@media_entry_1, 'Shared Title')
    check_resource_title(@media_entry_2, 'Media Entry 2')
    check_resource_title(@media_entry_3, 'Shared Title')
    check_resource_title(@collection_1, 'Collection 1')
    check_resource_title(@collection_2, 'Collection 2')
    check_resource_title(@collection_3, 'Collection 3')
  end

  scenario 'Update collections title' do
    prepare_and_login
    visit_batch(Collection, mixed_1_3_1_3)

    update_context_text_field('core', 'madek_core:title', 'Shared Title')
    click_save
    wait_until { current_path == my_dashboard_path }

    check_resource_title(@media_entry_1, 'Media Entry 1')
    check_resource_title(@media_entry_2, 'Media Entry 2')
    check_resource_title(@media_entry_3, 'Media Entry 3')
    check_resource_title(@collection_1, 'Shared Title')
    check_resource_title(@collection_2, 'Collection 2')
    check_resource_title(@collection_3, 'Shared Title')
  end

  def click_save
    find('.tab-content').find('.ui-actions')
      .find('button', text: I18n.t('meta_data_form_save')).click
  end

  def find_resource(resource)
    resource.class.find(resource.id)
  end

  def check_resource_title(resource, title)
    expect(find_resource(resource).title).to eq(title)
  end

  def find_thumbnail_titles(type)
    all('.' + resource_thumbnail_class(type) + '.ui-thumbnail')
  end

  def check_thumbnail_count_by_type(type, resources)
    resources_per_type = resources.select do |resource|
      resource.class == type
    end
    within('.ui-resources-selection') do
      expect(page).to have_selector(
        '.' + resource_thumbnail_class(type) + '.ui-thumbnail',
        count: resources_per_type.length
      )
    end
  end

  def check_thumbnail_count(resources)
    within('.ui-resources-selection') do
      expect(page).to have_selector('.ui-thumbnail', count: resources.length)
    end
  end

  def check_thumbnail_titles(resources)
    within('.ui-resources-selection') do
      resources.each do |resource|
        expect(page).to have_selector(
          '.ui-thumbnail .ui-thumbnail-meta-title', text: resource.title)
      end
    end
  end

  def batch_path(type)
    'batch_edit_context_meta_data_' + type.name.underscore.pluralize + '_path'
  end

  def visit_batch(type, resources)
    visit self.send(batch_path(type), id: resources, return_to: '/my')
  end

  def prepare_and_login
    prepare_user
    prepare_data
    login
  end
end
