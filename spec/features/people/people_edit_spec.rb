require_relative './_shared'

feature 'People' do
  given(:user) { User.find_by(login: 'normin') }
  given(:person) { user.person }
  given(:another_person) { create :person }
  given(:new_values) do
    {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      pseudonym: Faker::Name.title,
      description: Faker::Lorem.paragraph,
      external_uris: 2.times.map { Faker::Internet.url }
    }
  end

  context 'when user is a person owner' do
    scenario 'Showing edit button' do
      sign_in_as user.login

      within('.ui-header-user') do
        find('.dropdown-toggle').click
        find('.dropdown-menu a', text: I18n.t(:user_menu_my_person)).click
      end

      within('.ui-body-title-actions') do
        expect(page).to have_link(
          I18n.t(:person_show_edit_btn), href: edit_person_path(person)
        )
      end
    end

    scenario 'Editing' do
      sign_in_as user.login

      within('.ui-header-user') do
        find('.dropdown-toggle').click
        find('.dropdown-menu a', text: I18n.t(:user_menu_my_person)).click
      end

      within('.ui-body-title-actions') do
        click_link(I18n.t(:person_show_edit_btn))
      end

      expect(page).to have_current_path(edit_person_path(person))

      # fill_in 'person[first_name]', with: new_values[:first_name]
      # fill_in 'person[last_name]', with: new_values[:last_name]
      fill_in 'person[pseudonym]', with: new_values[:pseudonym]
      fill_in 'person[description]', with: new_values[:description]
      new_values[:external_uris].each { |uri| add_uri(uri) }

      submit_form

      expect(page).to have_current_path(person_path(person))
      expect(page).to have_css('.ui-alert.success')

      expect(page).to have_content(
        person[:first_name] + ' ' + person[:last_name] + ' (' + new_values[:pseudonym] + ')'
      )
      # expect_person_detail(:first_name, new_values)
      # expect_person_detail(:last_name, new_values)
      expect_person_detail(:description, new_values)
      expect(page).to have_content(
        [
          I18n.t(:person_show_external_uris),
          *new_values[:external_uris]
        ].join("\n")
      )
    end
  end

  context 'when user is not a person owner' do
    scenario 'Not showing edit button' do
      sign_in_as user.login
      # show button for myself (protect against false negative in next check)
      visit person_path(person)
      within('.ui-body-title-actions') do
        expect(page).to have_content(I18n.t(:person_show_edit_btn))
      end
      # dont show button for other person
      visit person_path(another_person)
      expect(page).not_to have_selector('.ui-body-title-actions')
      expect(page).not_to have_content(I18n.t(:person_show_edit_btn))
    end
  end
end
