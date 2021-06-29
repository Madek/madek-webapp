require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '_shared'

include Helpers

feature 'Finishing Workflow' do
  given(:user) { create(:user) }
  given!(:workflow) { create(:workflow, creator: user) }
  given!(:delegation) { create(:delegation) }
  given(:media_entry_1) { create(:media_entry) }
  given(:media_entry_2) { create(:media_entry) }
  given(:not_related_media_entry) { create(:media_entry) }
  given(:nested_media_entry) { create(:media_entry) }
  given(:nested_collection) { create(:collection_with_title) }

  background do
    Group.find(Madek::Constants::BETA_TESTERS_WORKFLOWS_GROUP_ID).users << user
    nested_collection.media_entries << nested_media_entry
    workflow.master_collection.media_entries << [media_entry_1, media_entry_2]
    workflow.master_collection.collections << nested_collection
  end

  scenario 'Finishing workflow with configured responsible delegation' do
    sign_in_as user

    visit edit_my_workflow_path(workflow)

    expand_section(:workflow_common_settings_permissions_title)

    autocomplete_and_choose_first(
      find('.row', text: I18n.t(:workflow_common_settings_permissions_select_user)),
      delegation.name
    )

    click_button(I18n.t(:workflow_edit_actions_save_data))

    expect(page).to have_content(
      [
        I18n.t(:workflow_common_settings_permissions_responsible),
        ': ',
        delegation.name,
        I18n.t(:app_autocomplete_user_delegation_postfix)
      ].join('')
    )

    expand_section(:workflow_common_settings_metadata_title)

    mandatory_meta_data.each { |meta_key_id| uncheck_is_mandatory(meta_key_id) }

    click_button(I18n.t(:workflow_edit_actions_save_data))
    click_link(I18n.t(:workflow_actions_validate))
    accept_confirm { click_button(I18n.t(:workflow_edit_actions_finish)) }

    expect(page).to have_css('.ui-alert', text: 'Workflow has been finished!')

    expect_delegation_for(workflow.master_collection, delegation)
    expect_delegation_for(media_entry_1, delegation)
    expect_delegation_for(media_entry_2, delegation)
    expect_delegation_for(nested_collection, delegation)
    expect_delegation_for(nested_media_entry, delegation)
    expect(not_related_media_entry.responsible_delegation_id).to be_nil
  end

  context 'when workflow grants public permissions for resources' do
    scenario 'resources will be visible for everyone' do
      sign_in_as user
      visit my_dashboard_path
      within('.ui-side-navigation') { click_link 'Workflows' }

      click_link I18n.t(:workflows_index_actions_new)
      fill_in 'Name', with: 'My test workflow'
      click_button I18n.t(:workflows_index_action_save)
      click_link 'Edit'

      upload_file

      expand_section(:workflow_common_settings_metadata_title)
      set_fixed_value 'zhdk_bereich:project_title', 'My test project'
      check_is_common 'madek_core:copyright_notice'
      uncheck_is_mandatory 'madek_core:authors'
      click_button(I18n.t(:workflow_edit_actions_save_data))

      click_link(I18n.t(:workflow_actions_validate))
      accept_confirm { click_button(I18n.t(:workflow_edit_actions_finish)) }
      expect(page).to have_css('.ui-alert', text: 'Workflow has been finished!')
      logout

      workflow = Workflow.find_by(name: 'My test workflow')

      visit collection_path(workflow.master_collection)
      expect(page).to have_css('.ui-body-title', text: 'My test workflow')

      click_link 'Grumpy Cat'
      expect(page).to have_css('.ui-body-title', text: 'Grumpy Cat')
    end
  end
end

def mandatory_meta_data
  %w(
    zhdk_bereich:project_title
    madek_core:title
    madek_core:authors
    madek_core:copyright_notice
    copyright:copyright_usage
    copyright:license
  )
end

def expect_delegation_for(resource, delegation)
  resource.reload
  expect(resource.responsible_user_id).to be_nil
  expect(resource.responsible_delegation_id).to eq(delegation.id)
end

def upload_file
  click_link I18n.t(:workflow_associated_collections_upload)
  select_file_and_submit(
    'images',
    'grumpy_cat_new.jpg',
    input_name: 'media_entry[media_file][]',
    make_visible: true
  )
end
