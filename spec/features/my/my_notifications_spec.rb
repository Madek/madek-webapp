require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'My: Notifications' do
  let(:user) { create :user }
  let(:beta_tester_group) { Group.find(Madek::Constants::BETA_TESTERS_NOTIFICATIONS_GROUP_ID) }
  let(:current_time) { Time.now.strftime("%H:%M") }

  background do
    notifications = [
      { id: '1', resource_label: "Foo1", user_fullname: "Bar" },
      { id: '2', resource_label: "Foo2", user_fullname: "Bar" },
      { id: '3', resource_label: "Foo3", user_fullname: "Bar" },
      { id: '4', resource_label: "Foo4", user_fullname: "Bar" },
      { id: '5', resource_label: "A muffin-like scone", user_fullname: "Mocha Joe", created_at: 2.days.ago },
      { id: '6', resource_label: "Best coffee in town", user_fullname: "Mocha Joe", created_at: 2.days.ago },
      { id: '7', resource_label: "A wobbly table", user_fullname: "Mocha Joe", created_at: 4.days.ago },
    ]
    notifications.each do |notification|
      user.notifications.create(
        notification_case_label: :transfer_responsibility, 
        data: {
          resource: { link_def: { label: notification[:resource_label], href: '/entries/' + notification[:id] } },
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
        "Verantwortlichkeit übertragen (7)\n" + 
        "Alle Notifikationen löschen\n" + 
        "#{Date.today.strftime("%d.%m.%Y")}\n(4)\n" +
        "#{2.days.ago.strftime("%d.%m.%Y")}\n(2)\n" +
        "#{current_time}\n–\nVerantwortlichkeit für Medieneintrag Best coffee in town wurde von Mocha Joe an Sie übertragen.\n" +
        "#{current_time}\n–\nVerantwortlichkeit für Medieneintrag A muffin-like scone wurde von Mocha Joe an Sie übertragen.\n" +
        "#{4.days.ago.strftime("%d.%m.%Y")}\n–\nVerantwortlichkeit für Medieneintrag A wobbly table wurde von Mocha Joe an Sie übertragen."
      )

      # expand the hidden notifications
      find("a", text: Date.today.strftime("%d.%m.%Y")).click
      expect(page).to have_text(
        "#{Date.today.strftime("%d.%m.%Y")}\n(4)\n" +
        "#{current_time}\n–\nVerantwortlichkeit für Medieneintrag Foo4 wurde von Bar an Sie übertragen.\n" +
        "#{current_time}\n–\nVerantwortlichkeit für Medieneintrag Foo3 wurde von Bar an Sie übertragen.\n" +
        "#{current_time}\n–\nVerantwortlichkeit für Medieneintrag Foo2 wurde von Bar an Sie übertragen.\n" +
        "#{current_time}\n–\nVerantwortlichkeit für Medieneintrag Foo1 wurde von Bar an Sie übertragen.\n"
      )

      # collapse 
      find("a", text: Date.today.strftime("%d.%m.%Y")).click
      expect(page).to have_text(
        "#{Date.today.strftime("%d.%m.%Y")}\n(4)\n" +
        "#{2.days.ago.strftime("%d.%m.%Y")}\n(2)\n"
      )
    end

    describe 'Acknowledge notifications' do
      it 'acknowledges' do
        visit my_dashboard_section_path(:notifications)

        sign_in_as user

        expect(page).to have_text "Verantwortlichkeit übertragen (7)\n"
        expect(page).to have_text "#{Date.today.strftime("%d.%m.%Y")}\n(4)"
        expect(page).to have_text "#{2.days.ago.strftime("%d.%m.%Y")}\n(2)"
        expect(page).to have_text "#{4.days.ago.strftime("%d.%m.%Y")}\n–"

        first(".button.small.icon-close").click

        expect(page).to have_text "Verantwortlichkeit übertragen (5)\n"
        expect(page).to have_text "#{Date.today.strftime("%d.%m.%Y")}\n(4)"
        expect(page).to have_text "#{4.days.ago.strftime("%d.%m.%Y")}\n–"

        accept_confirm "Wirklich alle löschen?" do
          first("button", text: "Alle Notifikationen löschen").click
        end
        expect(page).to have_text(
          "Verantwortlichkeit übertragen (0)\n" + 
          "Keine Einträge vorhanden\n"
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
