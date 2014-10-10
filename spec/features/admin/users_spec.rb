require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Admin Users" do
  background do
    sign_in_as "adam"
    visit "/app_admin/users"
  end

  scenario "Creating a new user with person" do
    click_link "New user with person"
    fill_in "person[last_name]", with: "Fischer"
    fill_in "person[first_name]", with: "Fritz"
    fill_in "user[login]", with: "fritzli"
    fill_in "user[email]", with: "fritzli@zhdk.ch"
    fill_in "user[password]", with: "new_password"
    click_button "Create"

    assert_success_message
    expect{ User.find_by!(login: "fritzli") }.not_to raise_error
  end

  scenario "Creating a new user for an existing person" do
    click_link "New user for existing person"
    fill_in "user[login]", with: "fritzli"
    fill_in "user[email]", with: "fritzli@zhdk.ch"
    fill_in "user[password]", with: "new_password"
    person = FactoryGirl.create :person
    fill_in "user[person_id]", with: person.id
    click_button "Create"

    assert_success_message
    expect{ User.find_by!(login: "fritzli") }.not_to raise_error
  end

  scenario "Loging-in as a newly created user" do
    click_link "New user with person"
    fill_in "person[last_name]", with: "Fischer"
    fill_in "person[first_name]", with: "Fritz"
    fill_in "user[login]", with: "fritzli"
    fill_in "user[email]", with: "fritzli@zhdk.ch"
    fill_in "user[password]", with: "new_password"
    click_button "Create"
    assert_success_message

    logout

    fill_in "login", with: "fritzli"
    fill_in "password", with: "new_password"
    click_button "Anmelden"
    accept_usage_terms
    expect(page).to have_css("a#user-action-button", text: "Fritz")
  end

  scenario "Deleting a user" do
    fill_in "filter[search_terms]", with: "beat"
    click_button "Apply"
    click_link "Details"
    click_link "Destroy"

    assert_success_message
  end

  scenario "Editing a user" do
    first("a", text: "Details").click
    click_link "Edit"
    fill_in "user[login]", with: "fritzli"
    fill_in "user[email]", with: "fritzli@zhdk.ch"
    click_button "Save"

    assert_success_message
  end

  scenario "Listing users with amount of resources" do
    expect(page).to have_css("th", text: "# of resources")
  end

  scenario "Sorting users by amount of resources" do
    select "Amount of resources", from: "sort_by"
    click_button "Apply"
    users_resources_amount = all("table tbody tr td.user-resources-amount").map(&:text).map(&:to_i)
    expect(users_resources_amount).to eq(users_resources_amount.sort.reverse)
    expect(find_field("sort_by")[:value]).to eq("resources_amount")
  end

  scenario "Listing detailed information about user's resources" do
    all("a", text: "Details").last.click
    expect(current_path).to match(//)
    table = find('table', match: :first)
    expect(table).to have_content("# Media Entries")
    expect(table).to have_content("# Media Sets")
    expect(table).to have_content("# Filter Sets")
  end

  scenario "Searching users by term" do
    fill_in "filter[search_terms]", with: "KAREN"
    click_button "Apply"
    expect_results_containing "karen"
  end

  scenario "Searching users by term containing leading and trailing spaces" do
    fill_in "filter[search_terms]", with: " KAren  "
    click_button "Apply"
    expect_results_containing "karen"
    expect(find_field("filter[search_terms]")[:value]).to eq("KAren")
  end

  scenario "Searching and ranking users by text search" do
    fill_in "filter[search_terms]", with: "kar"
    select "Text search ranking", from: "sort_by"
    click_button "Apply"
    expect(page).not_to have_content("Karen")

    fill_in "filter[search_terms]", with: "Karen"
    select "Text search ranking", from: "sort_by"
    click_button "Apply"
    expect_results_containing "Karen"
  end

  scenario "Searching and ranking users by trigram search", browser: :firefox do
    fill_in "filter[search_terms]", with: "kar"
    select "Trigram search ranking", from: "sort_by"
    click_button "Apply"
    expect(page).to have_content("Karen")
  end

  scenario "Filtering admin users" do
    check "filter[admins]"
    click_button "Apply"
    all('table tbody tr').each do |row|
      login = row.first('td').text
      expect(User.find_by(login: login).is_admin?).to be true
    end
  end

  scenario "Adding an user to admins" do
    expect(page).to have_content("Knacknuss, Karen")
    first("a", text: "Add to admins").click
    assert_success_message
    check "filter[admins]"
    click_button "Apply"
    expect(page).to have_content("Knacknuss, Karen")
  end

  scenario "Removing an user from admins" do
    first("a", text: "Add to admins").click
    visit "/app_admin/users?filter[admins]=true"
    expect(page).to have_content("Karen")
    all("a", text: "Details").last.click
    click_link "Remove from admins"
    assert_success_message
    visit "/app_admin/users?filter[admins]=true"
    expect(page).not_to have_content("Karen")
  end

  scenario "Switching to another admin user" do
    user = User.find_by!(login: 'karen')
    AdminUser.create!(user: user)

    check "filter[admins]"
    click_button "Apply"
    all("a", text: "Switch to").last.click
    visit "/"
    expect(page).to have_css("a#user-action-button", text: "Karen")

    visit "/app_admin"
    expect(current_path).to eq("/app_admin")
  end

  scenario "Switching to another user" do
    within find("table tbody tr", text: "karen") do
      click_link "Switch to"
    end
    expect(page).to have_css("a#user-action-button", text: "Karen")

    visit "/app_admin"
    expect(current_path).to eq("/my")
    expect(page).to have_css(".ui-alert.error", text: "Sie sind kein Administrator.")
  end

  def expect_results_containing(term)
    expect(all("table tbody tr", text: term).size).
      to eq(all("table tbody tr").size)
  end
end
