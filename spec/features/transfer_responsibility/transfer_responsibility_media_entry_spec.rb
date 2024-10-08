require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/batch_selection_helper'
include BatchSelectionHelper

require_relative './transfer_responsibility_shared'
include TransferResponsibilityShared

feature 'Media Entry - transfer responsibility' do

  scenario 'check media entry checkbox behaviour' do
    user = create(:user)
    media_entry = create_media_entry(user)
    login_user(user)
    open_permissions(media_entry)
    click_transfer_link
    check_checkboxes(MediaEntry, true, true, true, true)
    click_checkbox(:download)
    check_checkboxes(MediaEntry, true, false, false, false)
    click_checkbox(:manage)
    check_checkboxes(MediaEntry, true, true, true, true)
    click_checkbox(:edit)
    check_checkboxes(MediaEntry, true, true, false, false)
    click_checkbox(:edit)
    check_checkboxes(MediaEntry, true, true, true, false)
    click_checkbox(:view)
    check_checkboxes(MediaEntry, false, false, false, false)
    click_checkbox(:view)
    check_checkboxes(MediaEntry, true, false, false, false)
  end

  scenario 'transfer responsibility for media entry without new permissions' do
    user1 = create(:user)
    user2 = create(:user)
    user2.groups << Group.find(Madek::Constants::BETA_TESTERS_NOTIFICATIONS_GROUP_ID)

    media_entry = create_media_entry(user1)
    login_user(user1)
    open_permissions(media_entry)
    check_responsible_and_link(user1, true)
    click_transfer_link
    choose_user(user2)
    click_checkbox(:view)
    click_submit_button
    check_on_dashboard_after_loosing_view_rights
    open_permissions(media_entry)
    check_responsible_and_link(user2, false)
    check_no_permissions(user1, media_entry)
    check_notifications(user1, user2, media_entry)
  end

  scenario 'successful transfer responsibility for media entry' do
    user1 = create(:user)
    user2 = create(:user)
    media_entry = create_media_entry(user1)
    login_user(user1)
    open_permissions(media_entry)
    check_responsible_and_link(user1, true)
    click_transfer_link
    choose_user(user2)
    click_checkbox(:edit)
    click_submit_button
    check_responsible_and_link(user2, false)
    check_permissions(user1, media_entry, true, true, false, false)
  end

  context 'transfer responsibility to delegation and leave user with view permission' do
    before(:each) do
      @user = create(:user)
      @delegation = create(:delegation)
    end

    def transfer_responsibility_and_leave_user_with_view_permission
      media_entry = create_media_entry(@user)
      login_user(@user)
      open_permissions(media_entry)
      check_responsible_and_link(@user, true)
      click_transfer_link
      choose_delegation(@delegation)
      click_checkbox(:download)
      click_submit_button
      check_responsible_and_link(@delegation, false)
      open_permissions(media_entry)
      check_permissions(@user, media_entry, true, false, false, false)
    end

    scenario 'works' do
      transfer_responsibility_and_leave_user_with_view_permission
    end

    context 'different notification settings work' do
      before(:each) do
        @group = create(:group)

        # +--------------+------+-------+------------+
        # | name         | user | group | supervisor |
        # |--------------|------|-------|------------|
        # | del_member_1 | x    |       |            | 
        # | del_member_2 | x    | x     |            |
        # | del_member_3 |      | x     |            |
        # | del_member_4 | x    |       | x          |
        # | del_member_5 |      | x     | x          |
        # | del_member_6 |      |       | x          |
        # +--------------+------+-------+------------+

        @del_member_1 = create(:user)
        @del_member_1.groups << Group.find(Madek::Constants::BETA_TESTERS_NOTIFICATIONS_GROUP_ID)
        @del_member_2 = create(:user)
        @del_member_2.groups << Group.find(Madek::Constants::BETA_TESTERS_NOTIFICATIONS_GROUP_ID)
        @del_member_3 = create(:user)
        # (note: member 3 is not in beta tester group, should not get notifs)
        @del_member_4 = create(:user)
        @del_member_4.groups << Group.find(Madek::Constants::BETA_TESTERS_NOTIFICATIONS_GROUP_ID)
        @del_member_5 = create(:user)
        @del_member_5.groups << Group.find(Madek::Constants::BETA_TESTERS_NOTIFICATIONS_GROUP_ID)
        @del_member_6 = create(:user)
        # (note: member 6 is not in beta tester group, should not get notifs)

        @delegation.users << @del_member_1
        @delegation.users << @del_member_2
        @delegation.users << @del_member_4
        @group.users << @del_member_2
        @group.users << @del_member_3
        @group.users << @del_member_5
        @delegation.groups << @group
        @delegation.supervisors << @del_member_4
        @delegation.supervisors << @del_member_5
        @delegation.supervisors << @del_member_6

        ############################################################################

      end

      scenario 'notify all members & notifications email present' do
        @delegation.update!(notifications_email: 'delegation@example.com',
                            notify_all_members: true,
                            beta_tester_notifications: true)

        transfer_responsibility_and_leave_user_with_view_permission

        expect(Notification.count).to eq(5)
        [
          @del_member_1, 
          @del_member_2, 
          @del_member_4, 
          @del_member_5,
          nil
        ].each do |user|
           expect(Notification.find_by(user: user,
                                       notification_case_label: 'transfer_responsibility',
                                       via_delegation: @delegation))
             .to be_present
         end
      end

      scenario 'notify all members & notifications email not present' do
        @delegation.update!(notifications_email: nil,
                            notify_all_members: true,
                            beta_tester_notifications: true)

        transfer_responsibility_and_leave_user_with_view_permission

        expect(Notification.count).to eq(4)
        [
          @del_member_1, 
          @del_member_2, 
          @del_member_4, 
          @del_member_5
        ].each do |user|
          expect(Notification.find_by(user: user,
                                      notification_case_label: 'transfer_responsibility',
                                      via_delegation: @delegation))
            .to be_present
        end
      end

      scenario 'do not notify all members & notifications email present' do
        @delegation.update!(notifications_email: 'delegation@example.com',
                            notify_all_members: false,
                            beta_tester_notifications: true)

        transfer_responsibility_and_leave_user_with_view_permission

        # still notify all supervisors
        expect(Notification.count).to eq(3)
        [
          @del_member_4, 
          @del_member_5,
          nil
        ].each do |user|
          expect(Notification.find_by(user: user,
                                      notification_case_label: 'transfer_responsibility',
                                      via_delegation: @delegation))
            .to be_present
        end
      end

      scenario 'do not notify all members & notifications email not present' do
        @delegation.update!(notifications_email: nil,
                            notify_all_members: false,
                            beta_tester_notifications: true)

        transfer_responsibility_and_leave_user_with_view_permission

        # still notify all supervisors
        expect(Notification.count).to eq(2)
        [
          @del_member_4, 
          @del_member_5
        ].each do |user|
          expect(Notification.find_by(user: user,
                                      notification_case_label: 'transfer_responsibility',
                                      via_delegation: @delegation))
            .to be_present
        end
      end
    end
  end

  scenario 'transfer responsibility to delegation '\
           'and leave user with view & download permissions' do
    user = create(:user)
    delegation = create(:delegation)
    media_entry = create_media_entry(user)
    login_user(user)
    open_permissions(media_entry)
    check_responsible_and_link(user, true)
    click_transfer_link
    choose_delegation(delegation)
    click_checkbox(:edit)
    click_submit_button
    open_permissions(media_entry)
    check_permissions(user, media_entry, true, true, false, false)
  end

  scenario 'transfer responsibility to delegation '\
           'and leave user with all permissions except manage' do
    user = create(:user)
    delegation = create(:delegation)
    media_entry = create_media_entry(user)
    login_user(user)
    open_permissions(media_entry)
    check_responsible_and_link(user, true)
    click_transfer_link
    choose_delegation(delegation)
    click_checkbox(:manage)
    click_submit_button
    open_permissions(media_entry)
    check_permissions(user, media_entry, true, true, true, false)
  end

  scenario 'transfer responsibility to delegation and leave user with no permissions' do
    user = create(:user)
    delegation = create(:delegation)
    media_entry = create_media_entry(user)
    login_user(user)
    open_permissions(media_entry)
    check_responsible_and_link(user, true)
    click_transfer_link
    choose_delegation(delegation)
    click_checkbox(:view)
    click_submit_button
    check_on_dashboard_after_loosing_view_rights
    open_permissions(media_entry)
    check_no_permissions(user, media_entry)
  end

  context 'media entry without public rights' do
    let(:user) { create(:user) }
    let(:media_entry) { create_media_entry(user, public_rights: false) }
    let(:delegation) { create(:delegation) }

    scenario 'transfer responsibility to delegation and leave user with no permissions' do
      login_user(user)
      open_permissions(media_entry)
      click_transfer_link
      choose_delegation(delegation)
      click_checkbox(:view)
      click_submit_button
      check_on_dashboard_after_loosing_view_rights
      open_permissions(media_entry)
      expect(page).to have_content(I18n.t(:error_403_title))
    end

    scenario 'transfer responsibility to delegation and leave user with view permission' do
      login_user(user)
      open_permissions(media_entry)
      click_transfer_link
      choose_delegation(delegation)
      click_checkbox(:download)
      click_submit_button
      open_permissions(media_entry)
      check_permissions(user, media_entry, true, false, false, false)
    end

    scenario 'transfer responsibility to delegation '\
             'and leave user with view & download permissions' do
      login_user(user)
      open_permissions(media_entry)
      click_transfer_link
      choose_delegation(delegation)
      click_checkbox(:edit)
      click_submit_button
      open_permissions(media_entry)
      check_permissions(user, media_entry, true, true, false, false)
    end

    scenario 'transfer responsibility to delegation '\
             'and leave user with all permissions except manage' do
      login_user(user)
      open_permissions(media_entry)
      click_transfer_link
      choose_delegation(delegation)
      click_checkbox(:manage)
      click_submit_button
      open_permissions(media_entry)
      check_permissions(user, media_entry, true, true, true, false)
    end

    scenario 'transfer responsibility to delegation and leave user with all permissions' do
      login_user(user)
      open_permissions(media_entry)
      click_transfer_link
      choose_delegation(delegation)
      click_submit_button
      open_permissions(media_entry)
      check_permissions(user, media_entry, true, true, true, true)
    end

    context 'when user belongs to the delegation' do
      before { delegation.users << user }

      scenario 'transfer responsibility to delegation and leave user with no permissions' do
        login_user(user)
        open_permissions(media_entry)
        click_transfer_link
        choose_delegation(delegation)
        click_checkbox(:view)
        click_submit_button
        check_on_dashboard_after_loosing_view_rights
        open_permissions(media_entry)
        check_responsible_and_link(delegation, true)
      end
    end
  end

  scenario 'batch transfer responsibility for media entries' do
    user1 = create(:user)
    user2 = create(:user)
    media_entry1 = create_media_entry(user1, title: 'Media Entry 1')
    media_entry2 = create_media_entry(user2, title: 'Media Entry 2')
    media_entry3 = create_media_entry(user1, title: 'Media Entry 3')
    parent = create_collection(user1)

    all_media_entries = [media_entry1, media_entry2, media_entry3]
    add_all_to_parent(all_media_entries, parent)

    login_user(user1)
    open_resource(parent)
    click_select_all_on_first_page
    click_dropdown
    check_partial_dropdown(
      media_entries_transfer_responsibility: {
        count: 2,
        highlights: [media_entry1, media_entry3] }
    )
    click_batch_action(:media_entries_transfer_responsibility)

    choose_user(user2)
    click_submit_button

    open_resource(parent)
    click_select_all_on_first_page
    click_dropdown
    check_partial_dropdown(
      media_entries_transfer_responsibility: { count: 0, active: false }
    )
  end
end
