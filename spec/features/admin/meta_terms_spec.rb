require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'Admin Meta Terms' do
  background { sign_in_as "adam" }

  scenario "Listing meta terms" do
    visit "/app_admin"

    expect(page).to have_css(".dropdown > a", text: "Meta")
    within find(".dropdown > a", text: "Meta").first(:xpath, ".//..") do
      expect(page).to have_link("Meta Terms")
    end

    click_link "Meta"
    click_link "Meta Terms"

    expect(current_path).to eq("/app_admin/meta_terms")
    expect(page).to have_css("h1", text: "MetaTerms")
  end

  scenario "Transferring resources to another meta term" do
    visit "/app_admin/meta_terms?utf8=%E2%9C%93&filter_by=used"
    expect(all('.resource-count').size).to be > 0

    meta_term_with_resources = MetaTerm.reorder(:term, :id).joins(:meta_data).joins(:meta_keys).first

    find("tr#meta_term_#{meta_term_with_resources.id} a.transfer-resources-link").click
    fill_in "[id_receiver]", with: MetaTerm.reorder(:term, :id).first.id
    click_button "Transfer"

    expect(current_path).to eq("/app_admin/meta_terms")
    expect(page).to have_css(".alert-success")
    expect(page).not_to have_css("tr#meta_term_#{meta_term_with_resources.id} .resource-count")
  end

  scenario "Editing term value" do
    visit "/app_admin/meta_terms"

    all("table tbody tr").each do |row|
      expect(row).to have_link "Edit"
    end
    first("a", text: "Edit").click
    fill_in "meta_term[term]", with: "umbrella"
    click_button "Save"

    expect(page).to have_css(".alert-success")
    expect { MetaTerm.find_by!(term: "umbrella") }.not_to raise_error
  end

  scenario "Sorting by term in ascending order by default" do
    visit "/app_admin/meta_terms"

    expect(find_field("sort_by")[:value]).to eq("asc")
  end

  scenario "Searching meta terms by term" do
    visit "/app_admin/meta_terms"

    fill_in "filter[search_terms]", with: "zet"
    click_button "Apply"
    expect_results_containing "zett "

    fill_in "filter[search_terms]", with: "ZeTT"
    click_button "Apply"
    expect_results_containing "zett "
  end

  scenario "Searching and ranking meta terms by text search", browser: :firefox do
    visit "/app_admin/meta_terms"

    fill_in "filter[search_terms]", with: "tur"
    select "Text search ranking", from: "sort_by"
    click_button "Apply"
    expect(page).not_to have_content("Turm")

    fill_in "filter[search_terms]", with: "Turm"
    select "Text search ranking", from: "sort_by"
    click_button "Apply"
    expect_results_containing "Turm"
  end

  scenario "Searching and ranking meta terms by trigram search", browser: :firefox do
    visit "/app_admin/meta_terms"

    fill_in "filter[search_terms]", with: "tur"
    select "Trigram search ranking", from: "sort_by"
    click_button "Apply"
    expect(page).to have_content("Turm")
    expect(page).to have_content("tur")
  end

  scenario "Reseting searching, filtering and sorting" do
    visit "/app_admin/meta_terms/?filter[search_terms]=TERM&filter_by=used&sort_by=desc"

    expect(find_field("filter[search_terms]")[:value]).to eq("TERM")
    expect(find_field("filter_by")[:value]).to eq("used")
    expect(find_field("sort_by")[:value]).to eq("desc")

    click_link "Reset"

    expect(find_field("filter[search_terms]")[:value]).to be_nil
    expect(find_field("filter_by")[:value]).to eq("")
    expect(find_field("sort_by")[:value]).to eq("asc")
  end

  scenario "Deleting unused meta term" do
    visit "/app_admin/meta_terms"

    MetaTerm.create!(term: "UNUSED META TERM")
    select "Not used", from: "filter_by"
    click_button "Apply"
    expect(page).to have_content "UNUSED META TERM"
    click_link "Delete"

    expect(page).to have_css(".alert-success")
    expect{ MetaTerm.find_by!(term: "UNUSED META TERM") }.to raise_error(ActiveRecord::RecordNotFound)
  end

  def expect_results_containing(term)
    expect(all("table tbody tr", text: term).size).
      to eq(all("table tbody tr").size)
  end
end
