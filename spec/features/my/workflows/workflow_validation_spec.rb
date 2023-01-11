require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '_shared'

include Helpers

feature 'Workflow validation' do
  given(:user) { create(:user) }
  given!(:workflow) { create(:workflow, creator: user, name: 'My Project') }
  given!(:delegation) { create(:delegation) }
  given(:media_entry_1) { create(:media_entry) }
  given(:media_entry_2) { create(:media_entry) }
  given(:not_related_media_entry) { create(:media_entry) }
  given(:nested_media_entry) { create(:media_entry) }
  given(:nested_collection) { create(:collection_with_title) }
  given(:author_1) { create(:person) }
  given(:author_2) { create(:person) }

  background do
    Group.find(Madek::Constants::BETA_TESTERS_WORKFLOWS_GROUP_ID).users << user
    nested_collection.media_entries << nested_media_entry
    workflow.master_collection.media_entries << [media_entry_1, media_entry_2]
    workflow.master_collection.collections << nested_collection
  end

  scenario 'Check checkboxes in configuration' do
    sign_in_as user

    visit edit_my_workflow_path(workflow)

    expand_section(:workflow_common_settings_metadata_title)

    within find_section('zhdk_bereich:project_title') do
      expect(page).to have_checked_field('is_common')
      expect(page).to have_checked_field('is_mandatory')
      expect(page).to have_field('zhdk_bereich:project_title', with: '')
    end

    within find_section('madek_core:title') do
      expect(page).to have_no_checked_field('is_common')
      expect(page).to have_checked_field('is_mandatory')
      expect(page).to have_no_field('madek_core:title')
    end

    within find_section('madek_core:subtitle') do
      expect(page).to have_no_checked_field('is_common')
      expect(page).to have_no_checked_field('is_mandatory')
      expect(page).to have_no_field('madek_core:subtitle')
    end

    within find_section('madek_core:authors') do
      expect(page).to have_no_checked_field('is_common')
      expect(page).to have_checked_field('is_mandatory')
      expect(page).to have_no_css('input.ui-typeahead-input')
    end

    within find_section('media_object:creative_participants_roles') do
      expect(page).to have_no_checked_field('is_common')
      expect(page).to have_no_checked_field('is_mandatory')
      expect(page).to have_no_css('input.ui-typeahead-input')
    end

    within find_section('madek_core:keywords') do
      expect(page).to have_no_checked_field('is_common')
      expect(page).to have_no_checked_field('is_mandatory')
      expect(page).to have_no_css('input.ui-typeahead-input')
    end

    within find_section('media_content:type') do
      expect(page).to have_no_checked_field('is_common')
      expect(page).to have_no_checked_field('is_mandatory')
    end

    within find_section('madek_core:portrayed_object_date') do
      expect(page).to have_no_checked_field('is_common')
      expect(page).to have_no_checked_field('is_mandatory')
    end

    within find_section('madek_core:description') do
      expect(page).to have_no_checked_field('is_common')
      expect(page).to have_no_checked_field('is_mandatory')
    end

    within find_section('research_data:pid') do
      expect(page).to have_no_checked_field('is_common')
      expect(page).to have_no_checked_field('is_mandatory')
    end

    within find_section('madek_core:copyright_notice') do
      expect(page).to have_no_checked_field('is_common')
      expect(page).to have_checked_field('is_mandatory')
      expect(page).to have_no_field('madek_core:copyright_notice')
    end

    within find_section('copyright:license') do
      expect(page).to have_no_checked_field('is_common')
      expect(page).to have_checked_field('is_mandatory')
      expect(page).to have_no_field('copyright:license')
    end

    within find_section('copyright:copyright_usage') do
      expect(page).to have_no_checked_field('is_common')
      expect(page).to have_checked_field('is_mandatory')
    end

    within find_section('research_data:contact_for_reuse') do
      expect(page).to have_no_checked_field('is_common') # as it cannot be found in the system
      expect(page).to have_no_checked_field('is_mandatory')
      expect(page).to have_no_field('research_data:contact_for_reuse')
    end
  end

  scenario 'Display errors for media entries & collections in Fill Data mode' do
    sign_in_as user

    visit edit_my_workflow_path(workflow)

    click_link(I18n.t(:workflow_edit_actions_fill_data))

    check_validation_errors
  end

  scenario 'Display errors for media entries & collections in Preview mode' do
    sign_in_as user

    visit edit_my_workflow_path(workflow)

    click_link(I18n.t(:workflow_actions_validate))
    check_validation_errors

    expect(page).to have_button(I18n.t(:workflow_edit_actions_finish), disabled: true)
  end
end

def check_validation_errors
  expect(all('.ui-subsection', count: 5)).to be

  all('.ui-subsection').each do |subsection|
    within(subsection) do
      resource_type = subsection.first('details .title-s span').text
      mandatory_meta_data_for(resource_type).each do |meta_key_id|
        label = first(:xpath,
                      "./div[contains(@class, 'ui-container')]"\
                      "/div[contains(@class, 'app-body-content')]"\
                      "/fieldset/div[contains(@class, 'form-label') "\
                      "and contains(text(), '#{MetaKey.find(meta_key_id).label} *')]")

        fieldset = label.ancestor('fieldset')
        expect(fieldset[:class]).to match /error/
      end
    end
  end
end

def mandatory_meta_data_for(resource_type)
  case resource_type
  when 'MediaEntry'
    %w(
      zhdk_bereich:project_title
      madek_core:title
      madek_core:authors
      madek_core:copyright_notice
      copyright:copyright_usage
      copyright:license
    )
  when 'Collection'
    %w(
      madek_core:authors
      madek_core:copyright_notice
    )
    # note: "madek_core:title" is mandatory too, but prefilled
  else
    raise "Unknown resource type: '#{resource_type}'!"
  end
end
