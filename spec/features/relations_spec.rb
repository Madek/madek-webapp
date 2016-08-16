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
      check_relations(
        lambda_create_resources: lambda do
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
        end,
        lambda_check_resources: lambda do
          check_parents(['Parent1', 'Parent2'])
          check_siblings(['Sibling'])
          check_children(['Child1', 'Child2', 'Child3'])
        end
      )
    end
  end

  describe 'media entry', browser: :firefox do
    it 'check tab visibility' do
      check_tab_visibility(
        lambda_create_resource: -> () { create_media_entry('Child') }
      )
    end

    it 'check relations' do
      check_relations(
        lambda_create_resources: lambda do
          current_media_entry = create_media_entry('Current')
          parent_collection = create_collection('Parent')
          current_media_entry.parent_collections << parent_collection
          create_media_entry('Unused').parent_collections << parent_collection
          create_collection('Sibling1').parent_collections << parent_collection
          create_collection('Sibling2').parent_collections << parent_collection
          current_media_entry
        end,
        lambda_check_resources: lambda do
          check_parents(['Parent'])
          check_siblings(['Sibling1', 'Sibling2'])
          check_children(nil)
        end
      )
    end
  end

  private

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
    sections = {
      parents: '#set-relations-parents',
      siblings: '#set-relations-siblings',
      children: '#set-relations-children'
    }

    element_id = sections[section]

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

  def visit_resource(resource)
    if resource.class == MediaEntry
      visit media_entry_path(resource)
    else
      visit collection_path(resource)
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
