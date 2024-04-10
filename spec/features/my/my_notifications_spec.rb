require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'My: Notifications' do
  let(:user) { create :user }
  let(:beta_tester_group) { Group.find(Madek::Constants::BETA_TESTERS_NOTIFICATIONS_GROUP_ID) }
  let(:current_time) { Time.now.strftime("%H:%M") }

  background do
    notifications = [
      { resource_label: "Foo1", user_fullname: "Bar" },
      { resource_label: "Foo2", user_fullname: "Bar" },
      { resource_label: "Foo3", user_fullname: "Bar" },
      { resource_label: "Foo4", user_fullname: "Bar" },
      { resource_label: "A muffin-like scone", user_fullname: "Mocha Joe", created_at: 2.days.ago },
      { resource_label: "Best coffee in town", user_fullname: "Mocha Joe", created_at: 2.days.ago },
      { resource_label: "A wobbly table", user_fullname: "Mocha Joe", created_at: 4.days.ago },
    ]
    notifications.each do |notification|
      user.notifications.create(
        notification_case_label: :transfer_responsibility, 
        data: {
          resource: { link_def: { label: notification[:resource_label] } },
          user: { fullname: notification[:user_fullname] }
        },
        created_at: notification[:created_at]
      )
    end
  end

  context 'when user is a member of the beta-tester group' do
    background { beta_tester_group.users << user }

    it 'shows the notifications (expanded/collapsed)' do
      visit my_dashboard_section_path(:notifications)

      sign_in_as user

      expect(page).to have_content(I18n.t(:sitemap_notifications))
      expect(page).to have_text(
        "Verantwortlichkeit übertragen\n" + 
        "Alle Notifikationen löschen\n" + 
        "#{Date.today.strftime("%d.%m.%Y")}\n" +
        "#{2.days.ago.strftime("%d.%m.%Y")}\n" +
        "#{current_time} - Verantwortlichkeit von Best coffee in town wurde von Mocha Joe an Sie übertragen.\n" +
        "#{current_time} - Verantwortlichkeit von A muffin-like scone wurde von Mocha Joe an Sie übertragen.\n" +
        "#{4.days.ago.strftime("%d.%m.%Y")}\n" +
        "#{current_time} - Verantwortlichkeit von A wobbly table wurde von Mocha Joe an Sie übertragen."
      )

      # expand the hidden notifications
      find("h3", text: Date.today.strftime("%d.%m.%Y")).click
      expect(page).to have_text(
        "#{Date.today.strftime("%d.%m.%Y")}\n" +
        "#{current_time} - Verantwortlichkeit von Foo4 wurde von Bar an Sie übertragen.\n" +
        "#{current_time} - Verantwortlichkeit von Foo3 wurde von Bar an Sie übertragen.\n" +
        "#{current_time} - Verantwortlichkeit von Foo2 wurde von Bar an Sie übertragen.\n" +
        "#{current_time} - Verantwortlichkeit von Foo1 wurde von Bar an Sie übertragen.\n"
      )

      # collapse 
      find("h3", text: Date.today.strftime("%d.%m.%Y")).click
      expect(page).to have_text(
        "#{Date.today.strftime("%d.%m.%Y")}\n" +
        "#{2.days.ago.strftime("%d.%m.%Y")}\n"
      )
    end

    describe 'Acknowledge notifications' do
      it 'acknowledges' do
        visit my_dashboard_section_path(:notifications)

        sign_in_as user

        expect(page).to have_text(
          "#{2.days.ago.strftime("%d.%m.%Y")}\n" +
          "#{current_time} - Verantwortlichkeit von Best coffee in town wurde von Mocha Joe an Sie übertragen.\n" +
          "#{current_time} - Verantwortlichkeit von A muffin-like scone wurde von Mocha Joe an Sie übertragen.\n" +
          "#{4.days.ago.strftime("%d.%m.%Y")}\n"
        )

        first(".button.small.icon-close").click

        expect(page).to have_text(
          "#{2.days.ago.strftime("%d.%m.%Y")}\n" +
          "#{current_time} - Verantwortlichkeit von A muffin-like scone wurde von Mocha Joe an Sie übertragen.\n" +
          "#{4.days.ago.strftime("%d.%m.%Y")}\n"
        )

        first("button", text: "Alle Notifikationen löschen").click
        expect(page).to have_text(
          "Verantwortlichkeit übertragen\n" + 
          "Keine Notifikationen vorhanden\n"
          )
      end
    end
  end

  context 'when user is not a member of the beta-tester group' do
    it 'does not show the notifications, an error instead' do
      visit my_dashboard_section_path(:notifications)

      sign_in_as user

      expect(page).not_to have_content(I18n.t(:sitemap_notifications))
      expect(page).to have_content("No such dashboard section")
    end
  end

end
