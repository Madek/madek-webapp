require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './shared/basic_data_helper_spec'
include BasicDataHelper

feature 'relations' do

  describe 'collection', browser: :firefox do
    it 'check tab visibility' do
      check_tab_visibility(
        lambda_create_resource: -> () { create_collection('Child') }
      )
    end

    it 'check relations' do
      prepare_user
      login

      current_resource = prepare_collection
      visit_resource(current_resource)

      click_relations_tab
      check_parents(['Parent1', 'Parent2'])
      check_siblings(['Sibling'])
      check_children(['Child1', 'Child2', 'Child3'])

      check_show_all_parents(current_resource, ['Parent1', 'Parent2'])
      check_show_all_siblings(current_resource, ['Sibling'])
      check_show_all_children(current_resource, ['Child1', 'Child2', 'Child3'])
    end
  end

  describe 'media entry', browser: :firefox do
    it 'check tab visibility' do
      check_tab_visibility(
        lambda_create_resource: -> () { create_media_entry('Child') }
      )
    end

    it 'check relations' do
      prepare_user
      login

      current_resource = prepare_media_entry
      visit_resource(current_resource)

      click_relations_tab
      check_parents(['Parent'])
      check_siblings(['Sibling1', 'Sibling2'])
      check_children(nil)

      check_show_all_parents(current_resource, ['Parent'])
      check_show_all_siblings(current_resource, ['Sibling1', 'Sibling2'])
    end
  end

  private

  def check_show_all_parents(current_resource, expected_titles)
    visit_resource_relations(current_resource)
    click_show_all(:parents)
    check_show_all_title(:parents)
    check_show_all_box(expected_titles)
  end

  def check_show_all_siblings(current_resource, expected_titles)
    visit_resource_relations(current_resource)
    click_show_all(:siblings)
    check_show_all_title(:siblings)
    check_show_all_box(expected_titles)
  end

  def check_show_all_children(current_resource, expected_titles)
    visit_resource_relations(current_resource)
    click_show_all(:children)
    find('li.active.ui-tabs-item', text: 'Set')
    expect(
      current_url.end_with?(
        resource_path(current_resource) + '?type=collections'
      )
    ).to eq(true)
    check_show_all_box(expected_titles)
  end

  def prepare_media_entry
    current_media_entry = create_media_entry('Current')
    parent_collection = create_collection('Parent')
    current_media_entry.parent_collections << parent_collection
    create_media_entry('Unused').parent_collections << parent_collection
    create_collection('Sibling1').parent_collections << parent_collection
    create_collection('Sibling2').parent_collections << parent_collection
    current_media_entry
  end

  def prepare_collection
    current_collection = create_collection('Current')
    parent_collection1 = create_collection('Parent1')
    parent_collection2 = create_collection('Parent2')
    child_collection1 = create_collection('Child1')
    child_collection2 = create_collection('Child2')
    child_collection3 = create_collection('Child3')
    current_collection.parent_collections << parent_collection1
    current_collection.parent_collections << parent_collection2
    create_media_entry('Unused1').parent_collections << parent_collection1
    create_collection('Sibling').parent_collections << parent_collection1
    create_media_entry('Unused2').parent_collections << current_collection
    child_collection1.parent_collections << current_collection
    child_collection2.parent_collections << current_collection
    child_collection3.parent_collections << current_collection
    current_collection
  end

  def click_show_all(section_type)
    find(section_id(section_type)).find(
      'h2.ui-resource-title',
      text: I18n.t(title_key(section_type))
    ).find('a', text: I18n.t(:collection_relations_show_all)).click
  end

  def check_show_all_title(relation_type)
    within('.tab-content') do
      find('h2.title-l', text: I18n.t(title_key(relation_type)))
    end
  end

  def check_show_all_box(expected_titles)
    within('.tab-content') do
      within('.ui-polybox') do
        expect(page).to have_selector('.ui-filterbar', text: 'Filtern')
        within('ul.ui-resources-page-items') do
          resource_elements = all('.ui-resource')
          expect(resource_elements.length).to eq(expected_titles.length)
          expected_titles.each do |expected_title|
            find('.ui-resource', text: expected_title)
          end
        end
      end
    end
  end

  def title_key(section_type)
    mapping = {
      parents: :collection_relations_parent_sets,
      siblings: :collection_relations_sibling_sets,
      children: :collection_relations_child_sets
    }
    mapping[section_type]
  end

  def section_id(section_type)
    mapping = {
      parents: '#set-relations-parents',
      siblings: '#set-relations-siblings',
      children: '#set-relations-children'
    }
    mapping[section_type]
  end

  def check_parents(expected_titles)
    check_section(:parents, expected_titles)
  end

  def check_siblings(expected_titles)
    check_section(:siblings, expected_titles)
  end

  def check_children(expected_titles)
    check_section(:children, expected_titles)
  end

  def check_section(section, expected_titles)
    element_id = section_id(section)

    within('.app-body-ui-container') do
      if expected_titles.nil?
        expect(page).to have_no_css(element_id)
      else
        expect(page).to have_css(element_id)

        resource_elements = find(element_id).all('.ui-resource')
        expect(resource_elements.length).to eq(expected_titles.length)

        expected_titles.each do |expected_title|
          find('.ui-resource', text: expected_title)
        end
      end
    end
  end

  def click_relations_tab
    within('.app-body-ui-container') do
      find('.ui-tabs').find(
        '.ui-tabs-item',
        text: I18n.t(:media_entry_tab_relations)).click
    end
  end

  def check_relations(lambda_create_resources:, lambda_check_resources:)
    prepare_user
    login
    current_resource = lambda_create_resources.call
    visit_resource(current_resource)
    click_relations_tab
    lambda_check_resources.call
  end

  def visit_resource_relations(resource)
    if resource.class == MediaEntry
      visit relations_media_entry_path(resource)
    else
      visit relations_collection_path(resource)
    end
  end

  def visit_resource(resource)
    visit resource_path(resource)
  end

  def resource_path(resource)
    if resource.class == MediaEntry
      media_entry_path(resource)
    else
      collection_path(resource)
    end
  end

  def check_tab_visibility(lambda_create_resource:)
    prepare_user
    login

    current_resource = lambda_create_resource.call
    visit_resource(current_resource)

    check_tab_button(false)

    parent_collection = create_collection('Parent')
    current_resource.parent_collections << parent_collection
    visit_resource(current_resource)

    check_tab_button(true)
  end

  def check_tab_button(expect_visible)
    within('.app-body-ui-container') do
      if expect_visible
        expect(find('.ui-tabs')).to have_content(
          I18n.t(:media_entry_tab_relations))
      else
        expect(find('.ui-tabs')).to have_no_content(
          I18n.t(:media_entry_tab_relations))
      end
    end
  end
end
