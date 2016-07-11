require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../../features/shared/batch_permissions_helper'
include BatchPermissionsHelper

feature 'Batch update media entries permissions', browser: :firefox do
  it 'successfully updates permissions for all entries' do
    ################################ DATA ########################################
    setup_batch_permissions_test_data # from BatchPermissionsHelper

    sign_in_as @logged_in_user.login
    my_content_page = my_dashboard_section_path(:content_media_entries)

    # select and choose action
    visit my_content_page
    box = page.find('.ui-polybox')
    within(box) do
      within('.ui-filterbar') do
        find('.ui-filterbar-select').find('.icon-checkbox').click
        click_on 'Aktionen'
        find('.dropdown-menu a', text: 'Berechtigungen editieren').click
      end
    end

    # edit form opens:
    expect(current_path_with_query)
      .to eq batch_edit_permissions_media_entries_path(
        id: [@entry_2.id, @entry_1.id], return_to: my_content_page)

    within('form[name="ui-rights-management"]') do

      # check UI state for all cases (8, 10, 11 not relevant)
      expect_permission(@case_1_user, 'get_metadata_and_previews', true)
      expect_permission(@case_2_group, 'get_full_size', false)
      expect_permission(@case_2_api_client, 'get_full_size', false)
      expect_permission(@case_3_user, 'edit_metadata', 'mixed')
      expect_permission(@case_4_user, 'edit_permissions', 'mixed')
      expect_permission(@case_5_group, 'get_metadata_and_previews', 'mixed')
      expect_permission(@case_5_api_client, 'get_metadata_and_previews', 'mixed')
      expect_permission(@case_6_user, 'get_metadata_and_previews', true)
      expect_permission(@case_7_user, 'get_metadata_and_previews', false)
      expect_permission(@case_9_group, 'get_full_size', false)
      expect_permission(@case_9_api_client, 'get_full_size', false)
      expect_permission('Internet', 'get_metadata_and_previews', 'mixed')
      expect_permission('Internet', 'get_full_size', 'mixed')

      # set form state for all cases (1, 2, 3, 8, 12 not relevant)
      set_permission(@case_4_user, 'edit_permissions', true)
      set_permission(@case_5_group, 'get_metadata_and_previews', false)
      set_permission(@case_5_api_client, 'get_metadata_and_previews', false)
      set_permission(@case_6_user, 'get_metadata_and_previews', false)
      set_permission(@case_7_user, 'get_metadata_and_previews', true)
      set_permission(@case_9_group, 'get_full_size', false)
      set_permission(@case_9_api_client, 'get_full_size', false)

      add_subject(@case_10_user)
      set_permission(@case_10_user, 'get_metadata_and_previews', true)
      set_permission(@case_10_user, 'get_full_size', true)

      add_subject(@case_10_group)
      set_permission(@case_10_group, 'get_metadata_and_previews', true)
      set_permission(@case_10_group, 'get_full_size', true)

      add_subject(@case_10_api_client)
      set_permission(@case_10_api_client, 'get_metadata_and_previews', true)
      set_permission(@case_10_api_client, 'get_full_size', true)

      remove_subject(@case_11_user)
      remove_subject(@case_11_group)
      set_permission('Internet', 'get_full_size', true)

      # SAVE
      find('.primary-button').click
    end

    # assertions

    wait_until do
      find('.ui-alert.success', text: I18n.t(:permissions_batch_success))
    end

    expect(current_path_with_query).to eq my_content_page

    check_batch_permissions_results # from BatchPermissionsHelper
  end
end

def set_permission(subject, permission, state)
  expect([true, false]).to include state # state = true/false
  # NOTE: always click first to clear "indeterminate", or capybara fails to set it
  input = get_checkbox(subject, permission)
  input.click
  input.set(state)
end

def expect_permission(subject, permission, state)
  expect([true, false, 'mixed']).to include state # state = true/false/mixed
  # NOTE: 'mixed' looks like false, no easy way to distinguish, ignore for now:
  expected_state = (state == true) ? state : false
  expect(get_checkbox(subject, permission).checked?).to eq expected_state
end

def add_subject(subject)
  adders = all('.ui-add-subject')
  adder = case subject.class.name
          when 'User' then adders[0]
          when 'Group' then adders[1]
          when 'ApiClient' then adders[2]
  end

  autocomplete_and_choose_first(adder, subject_search_name(subject))
end

def remove_subject(subject)
  get_line(subject).find('.ui-rights-remove').click
end

def get_line(subject)
  find('tr', text: subject_name(subject))
end

def get_checkbox(subject, permission)
  get_line(subject).find('[name="' + permission + '"]')
end

def subject_name(subject)
  case subject.class.name
  when 'User' then subject.person.to_s
  when 'Group' then subject.name
  when 'ApiClient' then subject.login
  else subject
  end
end

def subject_search_name(subject)
  subject.class == User ? subject.login : subject_name(subject)
end
