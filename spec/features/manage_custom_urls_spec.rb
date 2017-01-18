require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative './shared/basic_data_helper_spec'
include BasicDataHelper

feature 'manage custom urls' do

  scenario 'check action button not shown when logged out for media entry' do
    prepare_user
    media_entry = create_media_entry('Media Entry')
    visit_resource(media_entry)
    check_disabled_action_button
  end

  scenario 'check action button not shown when logged out for collection' do
    prepare_user
    collection = create_collection('Collection')
    visit_resource(collection)
    check_disabled_action_button
  end

  scenario 'check action and back button working for media entry' do
    media_entry = create_user_and_media_entry
    scenario_action_and_back_button(media_entry)
  end

  scenario 'check action and back button working for collection' do
    collection = create_user_and_collection
    scenario_action_and_back_button(collection)
  end

  scenario 'check cancel button for media entry' do
    media_entry = create_user_and_media_entry
    scenario_cancel_button(media_entry)
  end

  scenario 'check cancel button for collection' do
    collection = create_user_and_collection
    scenario_cancel_button(collection)
  end

  scenario 'check creating first custom url for media entry' do
    media_entry = create_user_and_media_entry
    scenario_creating_first(media_entry)
  end

  scenario 'check creating first custom url for collection' do
    collection = create_user_and_collection
    scenario_creating_first(collection)
  end

  scenario 'check set primary custom url for media entry' do
    media_entry = create_user_and_media_entry
    scenario_set_primary(media_entry)
  end

  scenario 'check set primary custom url for media entry' do
    collection = create_user_and_collection
    scenario_set_primary(collection)
  end

  scenario 'check errors for media entry' do
    media_entry = create_user_and_media_entry
    scenario_check_errors(media_entry)
  end

  scenario 'check errors for collection' do
    collection = create_user_and_collection
    scenario_check_errors(collection)
  end

  scenario 'check transfer for media entry' do
    prepare_user
    login
    media_entry_1 = create_media_entry('Media Entry 1')
    media_entry_2 = create_media_entry('Media Entry 2')
    scenario_check_transfer(media_entry_1, media_entry_2)
  end

  scenario 'check transfer for collection' do
    prepare_user
    login
    collection_1 = create_collection('Collection 1')
    collection_2 = create_collection('Collection 2')
    scenario_check_transfer(collection_1, collection_2)
  end

  scenario 'check transfer not allowed for media entry' do
    prepare_user
    login
    media_entry_1 = create_media_entry('Media Entry 1')
    media_entry_2 = create_media_entry('Media Entry 2')
    scenario_transfer_not_allowed(media_entry_1, media_entry_2)
  end

  scenario 'check transfer not allowed for collection' do
    prepare_user
    login
    collection_1 = create_collection('Collection 1')
    collection_2 = create_collection('Collection 2')
    scenario_transfer_not_allowed(collection_1, collection_2)
  end

  scenario 'check cross transfer not allowed' do
    prepare_user
    login
    media_entry = create_media_entry('Media Entry')
    collection = create_collection('Collection')
    scenario_check_cross_transfer_not_allowed(media_entry, collection)
  end

  scenario 'check table content for media entry' do
    media_entry = create_user_and_media_entry
    scenario_table_content(media_entry)
  end

  scenario 'check table content for collection' do
    collection = create_user_and_collection
    scenario_table_content(collection)
  end

  scenario 'set uuid as primary for media entry' do
    media_entry = create_user_and_media_entry
    scenario_set_uuid_as_primary(media_entry)
  end

  scenario 'set uuid as primary for collection' do
    collection = create_user_and_collection
    scenario_set_uuid_as_primary(collection)
  end

  scenario 'transfer to media entry without primary' do
    prepare_user
    login
    media_entry_1 = create_media_entry('Media Entry 1')
    media_entry_2 = create_media_entry('Media Entry 2')
    scenario_transfer_to_resource_without_primary(media_entry_1, media_entry_2)
  end

  scenario 'transfer to collection without primary' do
    prepare_user
    login
    collection_1 = create_collection('Collection 1')
    collection_2 = create_collection('Collection 2')
    scenario_transfer_to_resource_without_primary(collection_1, collection_2)
  end

  private

  def scenario_transfer_to_resource_without_primary(resource1, resource2)
    part1_transfer_to_without_custom_url(resource1, resource2)
    part2_transfer_to_with_existing_custom_url(resource1, resource2)
  end

  def part1_transfer_to_without_custom_url(resource1, resource2)
    visit_custom_urls(resource1)
    check_table([{ name: resource1.id, primary: true }])
    open_fill_in_and_submit_address('transfer_address_1')
    open_fill_in_and_submit_address('transfer_address_2')
    check_table([{ name: resource1.id, primary: false },
                 { name: 'transfer_address_2', primary: false },
                 { name: 'transfer_address_1', primary: true }])

    visit_custom_urls(resource2)
    check_table([{ name: resource2.id, primary: true }])
    open_fill_in_and_submit_address('transfer_address_1')

    check_table([{ name: resource2.id, primary: false },
                 { name: 'transfer_address_1', primary: true }])

    visit_custom_urls(resource1)
    check_table([{ name: resource1.id, primary: true },
                 { name: 'transfer_address_2', primary: false }])
  end

  def part2_transfer_to_with_existing_custom_url(resource1, resource2)
    visit_custom_urls(resource2)
    click_set_as_primary_button(resource2.id)
    check_table([{ name: resource2.id, primary: true },
                 { name: 'transfer_address_1', primary: false }])

    open_fill_in_and_submit_address('transfer_address_2')
    check_table([{ name: resource2.id, primary: false },
                 { name: 'transfer_address_2', primary: true },
                 { name: 'transfer_address_1', primary: false }])

    visit_custom_urls(resource1)
    check_table([{ name: resource1.id, primary: true }])
  end

  def scenario_set_uuid_as_primary(resource)
    visit_custom_urls(resource)
    click_create_custom_url
    fill_in_address('address1')
    click_submit_button
    click_create_custom_url
    fill_in_address('address2')
    click_submit_button

    click_set_as_primary_button('address2')

    check_table([
                  { name: resource.id, primary: false },
                  { name: 'address2', primary: true },
                  { name: 'address1', primary: false }
                ])

    click_set_as_primary_button(resource.id)

    check_table([
                  { name: resource.id, primary: true },
                  { name: 'address2', primary: false },
                  { name: 'address1', primary: false }
                ])
  end

  def scenario_table_content(resource)
    visit_custom_urls(resource)
    click_create_custom_url
    fill_in_address('address1')
    click_submit_button
    click_create_custom_url
    fill_in_address('address3')
    click_submit_button
    click_create_custom_url
    fill_in_address('address2')
    click_submit_button

    click_set_as_primary_button('address3')

    check_table(
      [
        { name: resource.id, primary: false },
        { name: 'address2', primary: false },
        { name: 'address3', primary: true },
        { name: 'address1', primary: false }
      ]
    )
  end

  def scenario_check_cross_transfer_not_allowed(resource1, resource2)
    visit_custom_urls(resource1)
    click_create_custom_url
    fill_in_address('address1')
    click_submit_button

    visit_custom_urls(resource2)
    click_create_custom_url
    fill_in_address('address2')
    click_submit_button

    visit_custom_urls(resource1)
    click_create_custom_url
    fill_in_address('address2')
    click_submit_button
    check_already_exists_flash('address2')

    visit_custom_urls(resource2)
    click_create_custom_url
    fill_in_address('address1')
    click_submit_button
    check_already_exists_flash('address1')
  end

  def scenario_transfer_not_allowed(resource1, resource2)
    visit_custom_urls(resource1)
    click_create_custom_url
    fill_in_address('address_shared')
    click_submit_button

    resource1.responsible_user = FactoryGirl.create(:user)
    resource1.save
    resource1.reload

    visit_custom_urls(resource2)
    click_create_custom_url
    fill_in_address('address_shared')
    click_submit_button

    check_already_exists_flash('address_shared')
  end

  def scenario_check_transfer(resource1, resource2)
    visit_custom_urls(resource1)
    click_create_custom_url
    fill_in_address('address1')
    click_submit_button

    visit_custom_urls(resource2)
    click_create_custom_url
    fill_in_address('address2')
    click_submit_button

    visit_custom_urls(resource1)
    click_create_custom_url
    fill_in_address('address2')
    click_submit_button

    check_transfer_success_flash('address2', resource2, resource1)
  end

  def scenario_check_errors(resource)
    visit_custom_urls(resource)
    click_create_custom_url

    click_submit_button
    check_input_empty_flash

    fill_in_address('---')
    click_submit_button
    check_wrong_format_flash('---')

    fill_in_address('first_address_name')
    click_submit_button
    click_create_custom_url
    fill_in_address('first_address_name')
    click_submit_button
    check_already_exists_flash('first_address_name')
  end

  def scenario_set_primary(resource)
    visit_custom_urls(resource)
    click_create_custom_url
    fill_in_address('first_address_name')
    click_submit_button
    check_overview_custom_url(resource, 'first_address_name')
    click_create_custom_url
    fill_in_address('second_address_name')
    click_submit_button
    check_overview_custom_url(resource, 'first_address_name')
    click_set_as_primary_button('second_address_name')
    check_overview_custom_url(resource, 'second_address_name')
    check_set_primary_flash('second_address_name')
  end

  def scenario_action_and_back_button(resource)
    visit_resource(resource)
    click_action_button
    check_uuid_custom_urls_page(resource)
    check_empty_addresses(resource)
    click_back_button
    check_uuid_resource_page(resource)
  end

  def scenario_cancel_button(resource)
    visit_edit_custom_urls(resource)
    click_cancel_button
    check_uuid_custom_urls_page(resource)
  end

  def scenario_creating_first(resource)
    visit_custom_urls(resource)
    check_uuid_custom_urls_page(resource)
    click_create_custom_url
    check_overview_uuid_url(resource)
    check_edit_title
    fill_in_address('primary_address_name')
    click_submit_button
    check_overview_custom_url(resource, 'primary_address_name')
    check_created_success_flash('primary_address_name')
  end

  def open_fill_in_and_submit_address(address_name)
    click_create_custom_url
    fill_in_address(address_name)
    click_submit_button
  end

  def check_input_empty_flash
    find('.ui-alert', text: I18n.t('custom_urls_flash_empty'))
  end

  def check_transfer_success_flash(address_name, resource1, resource2)
    text = concat_k1_v1_k2_v2_k3_v3(
      :custom_urls_flash_transfer_successful_1,
      address_name,
      :custom_urls_flash_transfer_successful_2,
      resource1.title,
      :custom_urls_flash_transfer_successful_3,
      resource2.title
    )
    find('.ui-alert', text: text)
  end

  def check_already_exists_flash(address_name)
    text = concat_k1_v1_k2(
      :custom_urls_flash_exists_1,
      address_name,
      :custom_urls_flash_exists_2
    )
    find('.ui-alert', text: text)
  end

  def check_wrong_format_flash(address_name)
    text = concat_k1_v1_k2(
      :custom_urls_flash_wrong_format_1,
      address_name,
      :custom_urls_flash_wrong_format_2
    )
    find('.ui-alert', text: text)
  end

  def check_created_success_flash(address_name)
    text = concat_k1_v1_k2(
      :custom_urls_flash_create_successful_1,
      address_name,
      :custom_urls_flash_create_successful_2
    )
    find('.ui-alert', text: text)
  end

  def check_set_primary_flash(address_name)
    text = concat_k1_v1_k2(
      :custom_urls_flash_primary_url_set_1,
      address_name,
      :custom_urls_flash_primary_url_set_2
    )
    find('.ui-alert', text: text)
  end

  def visit_resource(resource)
    path = send("#{resource.class.name.underscore}_path", resource)
    visit path
  end

  def visit_edit_custom_urls(resource)
    path = send(
      "edit_custom_urls_#{resource.class.name.underscore}_path",
      resource)
    visit path
  end

  def visit_custom_urls(resource)
    path = send(
      "custom_urls_#{resource.class.name.underscore}_path",
      resource)
    visit path
  end

  def fill_in_address(address_name)
    fill_in('custom_url_name', with: address_name)
  end

  def click_set_as_primary_button(address_name)
    find('tr', text: address_name)
      .find('button', text: I18n.t('edit_custom_urls_set_primary')).click
  end

  def create_user_and_collection
    prepare_user
    login
    create_collection('Collection')
  end

  def create_user_and_media_entry
    prepare_user
    login
    create_media_entry('Media Entry')
  end

  def click_submit_button
    find('.ui-actions').find(
      '.primary-button',
      text: I18n.t('edit_custom_urls_create_or_transfer')).click
  end

  def click_cancel_button
    find('.ui-actions').find(
      'a', text: I18n.t('edit_custom_urls_cancel')).click
  end

  def click_create_custom_url
    find('.ui-body-title-actions')
      .find('.primary-button', text: I18n.t('custom_urls_new')).click
  end

  def check_table(expected_rows)
    rows = find('table').all('tr')
    rows = rows.map { |row| row }
    rows.shift
    expect(rows.length).to eq(expected_rows.length)

    rows.zip(expected_rows).each do |pair|
      row = pair[0]
      expected_row = pair[1]

      expect(row).to have_selector('td', text: expected_row[:name], count: 1)

      if expected_row[:primary]
        expect(row).to have_content(I18n.t(:edit_custom_urls_state_primary))
        expect(row).to have_no_selector(
          '.button',
          text: I18n.t(:edit_custom_urls_set_primary))
      else
        expect(row).to have_content(I18n.t(:edit_custom_urls_state_transfer))
        expect(row).to have_selector(
          '.button',
          text: I18n.t(:edit_custom_urls_set_primary))
      end
    end
  end

  def check_uuid_resource_page(resource)
    wait_until do
      expected = send("#{resource.class.name.underscore}_path", resource)
      expect(current_path).to eq(expected)
    end
  end

  def check_overview_uuid_url(resource)
    wait_until do
      expected = send(
        "edit_custom_urls_#{resource.class.name.underscore}_path",
        resource)
      expect(current_path).to eq(expected)
    end
  end

  def check_overview_custom_url(resource, address_name)
    wait_until do
      base = { MediaEntry => 'entries', Collection => 'sets' }
      expected =
        "/#{base[resource.class]}" \
        "/#{address_name}/custom_urls"
      expect(current_path).to eq(expected)
    end
  end

  def check_uuid_custom_urls_page(resource)
    wait_until do
      expected = send(
        "custom_urls_#{resource.class.name.underscore}_path",
        resource)
      expect(current_path).to eq(expected)
    end
  end

  def click_back_button
    find('.ui-actions')
      .find('a.button', text: I18n.t('edit_custom_urls_back')).click
  end

  def check_disabled_action_button
    within '.ui-body-title-actions' do
      expect(page).to have_no_selector('.icon-vis-graph')
    end
  end

  def click_action_button
    find('.ui-body-title-actions').find('.icon-vis-graph').click
  end

  def concat_k1_v1(k1, v1)
    "#{I18n.t(k1)}\"#{v1}\""
  end

  def concat_k1_v1_k2(k1, v1, k2)
    "#{I18n.t(k1)}\"#{v1}\"#{I18n.t(k2)}"
  end

  def concat_k1_v1_k2_v2_k3_v3(k1, v1, k2, v2, k3, v3)
    "#{I18n.t(k1)}\"#{v1}\"#{I18n.t(k2)}\"#{v2}\"#{I18n.t(k3)}\"#{v3}\""
  end

  def check_empty_addresses(resource)
    check_table([{ name: resource.id, primary: true }])
  end

  def check_edit_title
    find('.title-xl', text: I18n.t('edit_custom_urls_create_or_transfer'))
  end

end
