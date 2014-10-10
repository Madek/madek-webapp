require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Admin People" do
  background { sign_in_as "adam" }

  scenario "Changing MetaData to a person" do
    visit "/app_admin/people?utf8=%E2%9C%93&with_meta_data=1"

    expect(all(".meta_data_count").size).to eq(all("table tbody tr").size)

    person_with_meta_data = Person.reorder(:created_at, :id).joins(:meta_data).first
    expect(page).to have_css("tr#person_#{person_with_meta_data.id} a.transfer_meta_data_link")

    find("tr#person_#{person_with_meta_data.id} a.transfer_meta_data_link").click
    fill_in "id_receiver", with: Person.reorder(:created_at, :id).first.id
    click_button "Transfer"

    expect(current_path).to eq("/app_admin/people")
    expect(page).not_to have_css("tr#person_#{person_with_meta_data.id} .meta_data_count")
  end

  scenario "Deleting a person" do
    visit "/app_admin/people"

    person_without_meta_data = Person.reorder(:created_at,:id).
      where(%[ NOT EXISTS (SELECT true FROM users WHERE users.person_id = people.id)]).first
    ActiveRecord::Base.connection.execute %Q{
      delete from meta_data_people where person_id = '#{person_without_meta_data.id}' }
    visit(current_path)
    expect(page).not_to have_css("tr#person_#{person_without_meta_data.id} .meta_data_count")

    fill_in "filter[search_terms]", with: person_without_meta_data.last_name
    click_button "Apply"
    expect(page).to have_css("tr#person_#{person_without_meta_data.id} a", text: "Delete")

    find("tr#person_#{person_without_meta_data.id} a", text: "Delete").click
    expect(page).to have_css(".alert-success")
    expect { Person.find(person_without_meta_data.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  scenario "Preventing delete people that have metadata" do
    visit "/app_admin/people"

    person_with_meta_data = Person.reorder(:created_at, :id).joins(:meta_data).first
    within "tr#person_#{person_with_meta_data.id}" do
      expect(page).to have_link("transfer #{person_with_meta_data.meta_data.count} to ...")
      expect(page).not_to have_link("Delete")
    end
    expect(page).to have_css("tr#person_#{person_with_meta_data.id} a.transfer_meta_data_link")
    expect{ find("tr#person_#{@person_without_meta_data.id} a",text: 'Delete')}.to raise_error
  end

  scenario "Editing person" do
    visit "/app_admin/people"

    first("a", text: "Edit").click
    fill_in "person[last_name]", with: "LAST_NAME"
    fill_in "person[first_name]", with: "FIRST_NAME"
    fill_in "person[pseudonym]", with: "PSEUDONYM"
    fill_in "person[date_of_birth]", with: "10.04.1989"
    click_button "Save"

    expect(page).to have_css(".alert-success")
    expect(page).to have_content("LAST_NAME")
    expect(page).to have_content("FIRST_NAME")
    expect(page).to have_content("PSEUDONYM")
    expect(page).to have_content("1989-04-10")
  end

  scenario "Default sorting" do
    visit "/app_admin/people"

    expect(find_field("sort_by")[:value]).to eq("last_name_first_name")
    expect(first("table tbody tr").text).to include("Admin")    
  end

  scenario "Sorting by date of creation" do
    visit "/app_admin/people"

    select "Date of creation", from: "sort_by"
    click_button "Apply"
    expect(first("table tbody tr").text).to include("Pape")
  end

  scenario "Searching people" do
    visit "/app_admin/people"

    fill_in "filter[search_terms]", with: "ann"
    click_button "Apply"
    all("table tbody tr").each do |row|
      expect(row).to have_content("ann")
    end
  end

  scenario "Searching people by term containing leading and trailing spaces" do
    visit "/app_admin/people"

    fill_in "filter[search_terms]", with: "  ann "
    click_button "Apply"
    all("table tbody tr").each do |row|
      expect(row).to have_content("ann")
    end
    expect(find_field("filter[search_terms]")[:value]).to eq("ann")
  end
end
