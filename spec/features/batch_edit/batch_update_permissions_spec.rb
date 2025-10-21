require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../../features/shared/batch_permissions_helper'
include BatchPermissionsHelper

feature 'Batch update media entries permissions' do
  it 'offers action for CollectionChildren' do
    # NOTE: only Entries as children are tested!
    #        for this scenario we also don't really need the "big setup"…
    setup_batch_permissions_test_data(MediaEntry) # from BatchPermissionsHelper

    @collection = FactoryBot.create(
      :collection, responsible_user: @logged_in_user)
    @collection.media_entries << [@resource_1, @resource_2]
    sign_in_as @logged_in_user.login

    visit collection_path(@collection)
    select_all_in_box_and_choose_from_menu(
      'Berechtigungen von Medieneinträgen editieren')

    # edit form opens:
    expect(current_path_with_query).to eq(
      batch_edit_permissions_media_entries_path
    )
    check_resources([@resource_2, @resource_1])
    cancel_and_check_return_to(collection_path(@collection))
  end

  it 'successfully updates permissions for all Entries' do
    setup_batch_permissions_test_data(MediaEntry) # from BatchPermissionsHelper

    sign_in_as @logged_in_user.login
    my_content_page = my_dashboard_section_path(:content_media_entries)

    # select and choose action
    visit my_content_page
    select_all_in_box_and_choose_from_menu(
      'Berechtigungen von Medieneinträgen editieren')

    # edit form opens:
    expect(current_path_with_query).to eq(
      batch_edit_permissions_media_entries_path
    )
    check_resources([@resource_2, @resource_1])

    within('form[name="ui-rights-management"]') do
      check_displayed_permission_cases(MediaEntry)
      edit_permission_form_cases(MediaEntry)
      # SAVE
      find('.primary-button').click
    end

    expect(current_path).to eq(my_content_page)

    # assertions

    wait_until do
      find('.ui-alert.success', text: I18n.t(:permissions_batch_success))
    end

    expect(current_path_with_query).to eq my_content_page

    check_batch_permissions_results(MediaEntry) # from BatchPermissionsHelper
  end

  it 'successfully updates permissions for all Collections' do
    setup_batch_permissions_test_data(Collection) # from BatchPermissionsHelper

    sign_in_as @logged_in_user.login
    my_content_page = my_dashboard_section_path(:content_collections)

    # select and choose action
    visit my_content_page
    select_all_in_box_and_choose_from_menu('Berechtigungen von Sets editieren')

    # edit form opens:
    expect(current_path_with_query).to eq(
      batch_edit_permissions_collections_path
    )

    check_resources([@resource_2, @resource_1])

    within('form[name="ui-rights-management"]') do
      check_displayed_permission_cases(Collection)
      edit_permission_form_cases(Collection)
      # SAVE
      find('.primary-button').click
    end

    expect(current_path).to eq(my_content_page)

    # assertions

    wait_until do
      find('.ui-alert.success', text: I18n.t(:permissions_batch_success))
    end

    expect(current_path_with_query).to eq my_content_page
    check_batch_permissions_results(Collection) # from BatchPermissionsHelper
  end
end

def check_displayed_permission_cases(resource_class)
  # check UI state for all cases (8, 10, 11 not relevant)
  expect_permission(@case_1_user, 'get_metadata_and_previews', true)
  expect_permission(@case_2_group, 'get_metadata_and_previews', false)
  expect_permission(@case_2_api_client, 'get_metadata_and_previews', false)
  expect_permission(@case_3_user, 'get_metadata_and_previews', 'mixed')
  expect_permission(@case_4_user, 'edit_permissions', 'mixed')
  expect_permission(@case_5_group, 'get_metadata_and_previews', 'mixed')
  expect_permission(@case_5_api_client, 'get_metadata_and_previews', 'mixed')
  expect_permission(@case_6_user, 'get_metadata_and_previews', true)
  expect_permission(@case_7_user, 'get_metadata_and_previews', false)
  expect_permission(@case_9_group, 'get_metadata_and_previews', false)
  expect_permission(@case_9_api_client, 'get_metadata_and_previews', false)
  if resource_class == MediaEntry
    expect_permission('Internet', 'get_metadata_and_previews', 'mixed')
    expect_permission('Internet', 'get_full_size', 'mixed')
  end
end

def edit_permission_form_cases(_resource_class)
  # set form state for all cases (1, 2, 3, 8, 13 not relevant)

  set_permission(@case_4_user, 'edit_permissions', true)
  set_permission(@case_5_group, 'get_metadata_and_previews', false)
  set_permission(@case_5_api_client, 'get_metadata_and_previews', false)
  set_permission(@case_6_user, 'get_metadata_and_previews', false)
  set_permission(@case_7_user, 'get_metadata_and_previews', true)
  set_permission(@case_9_group, 'get_metadata_and_previews', false)
  set_permission(@case_9_api_client, 'get_metadata_and_previews', false)

  add_subject(@case_10_user)
  # NOTE: the following is enforced by UI, by not setting it we test this
  # set_permission(@case_10_user, 'get_metadata_and_previews', true)
  set_permission(@case_10_user, 'edit_permissions', true)

  add_subject(@case_10_group)
  set_permission(@case_10_group, 'get_metadata_and_previews', true)

  add_subject(@case_10_api_client)
  set_permission(@case_10_api_client, 'get_metadata_and_previews', true)

  add_subject(@case_10_delegation)
  set_permission(@case_10_delegation, 'get_metadata_and_previews', true)

  remove_subject(@case_11_user)
  remove_subject(@case_11_delegation)
  remove_subject(@case_11_group)
  set_permission('Internet', 'get_metadata_and_previews', true)
end

def select_all_in_box_and_choose_from_menu(text)
  click_select_all_on_first_page
  within(page.find('.ui-polybox')) do
    within('.ui-filterbar') do
      find('.dropdown-toggle, .ui-drop-toggle', text: 'Aktionen').click
      find('.dropdown-menu a', text: text).click
    end
  end
end

def set_permission(subject, permission, state)
  expect([true, false]).to include state
  input = get_checkbox(subject, permission)
  # NOTE: always click first to clear "in determinate", or capybara fails to set it
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
  adder =
    case subject.class.name
    when 'User' then adders[0]
    when 'Delegation' then adders[0]
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
  when 'User' then subject.to_s
  when 'Group' then subject.name
  when 'ApiClient' then subject.login
  when 'Delegation' then subject.name
  when 'String' then subject
  end
end

def subject_search_name(subject)
  subject.class == User ? subject.login : subject_name(subject)
end

def cancel_and_check_return_to(expected)
  within('.ui-actions') do
    find('a', text: I18n.t('permissions_table_cancel_btn')).click
    expect(current_path).to eq(expected)
  end
end

def check_resources(resources)
  within('.ui-resources-holder') do
    resources.each do |r|
      base = \
        if r.class == MediaEntry then 'entries'
        elsif r.class == Collection then 'sets'
        else
          throw 'unexpected'
        end
      href = '/' + base + '/' + r.id
      find('.ui-resource a[href="' + href + '"]')
    end
  end
end
