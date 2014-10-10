require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Admin Keywords" do
  background do
    sign_in_as "adam"
  end

  scenario "Listing keywords" do
    visit "/app_admin"

    dropdown = find("a.dropdown-toggle", text: "Meta").find(:xpath, '..').find('ul.dropdown-menu')

    expect(dropdown).to have_css("a", text: "Keywords")

    within dropdown do
      click_link "Keywords"
    end

    expect(current_path).to eq "/app_admin/keywords"
    expect(page).to have_css("h1", text: "Keywords")
  end

  scenario "Transferring media entries to another keyword", browser: :firefox do
    visit "/app_admin/keywords?sort_by=used_times_desc"

    keyword_with_resources = KeywordTerm.with_count.order("keywords_count DESC").first
    keyword_receiver = KeywordTerm.with_count.order("keywords_count DESC").last

    keyword_transfer_link = find("tr#keyword-term-#{keyword_with_resources.id} a.transfer-resources")
    expect(keyword_transfer_link).not_to be_nil
    
    keyword_transfer_link.click
    find_field("id_receiver").set(keyword_receiver.id)
    click_button "Transfer"

    expect(page).to have_css(".alert-success")
    expect(page).not_to have_css("tr#keyword-term-#{keyword_with_resources.id} a.transfer-resources")
  end

  scenario "Editing keyword term" do
    visit "/app_admin/keywords"

    expect(page).to have_css("table tbody tr", text: "sq6")

    first("a", text: "Edit").click
    fill_in "keyword[term]", with: "TERM"
    click_button "Save"

    expect(page).to have_css(".alert-success")
    expect(page).not_to have_css("table tbody tr", text: "sq6")
    expect(page).to have_css("table tbody tr", text: "TERM")
  end

  scenario "Searching keywords by term" do
    visit "/app_admin/keywords"

    fill_in "search_term", with: "sq6"
    click_button "Apply"
    expect(all("table tbody tr", text: "sq6").count).to eq(all("table tbody tr").count)

    fill_in "search_term", with: "SQ"
    click_button "Apply"
    expect(all("table tbody tr", text: "sq6").count).to eq(all("table tbody tr").count)
  end

  scenario "Searching keywords by creator" do
    visit "/app_admin/keywords"

    fill_in "search_term", with: "liselotte"
    select "Creator", from: "search_by"
    click_button "Apply"
    expect(all("table tbody tr", text: "Liselotte").count).to eq(all("table tbody tr").count)
  end

  scenario "Searching and ranking keywords by text search", browser: :firefox do
    visit "/app_admin/keywords"

    fill_in "search_term", with: "wolke"
    select "Text search ranking", from: "sort_by"
    click_button "Apply"
    expect(page).not_to have_css("table tbody tr", text: "Wolken")
  
    fill_in "search_term", with: "wolken"
    select "Text search ranking", from: "sort_by"
    click_button "Apply"
    expect(page).to have_css("table tbody tr", text: "Wolken")
  end

  scenario "Searching and ranking keywords by trigram search", browser: :firefox do
    visit "/app_admin/keywords"

    fill_in "search_term", with: "wolke"
    select "Trigram search ranking", from: "sort_by"
    click_button "Apply"
    expect(page).to have_css("table tbody tr", text: "Wolken")
  end

  scenario "Reseting searching, filtering and sorting" do
    visit "/app_admin/keywords/?search_term=TERM&sort_by=used_times_desc"

    expect(find_field("search_term")[:value]).to eq "TERM"
    expect(find_field("sort_by")[:value]).to eq "used_times_desc"

    click_link "Reset"
    expect(find_field("search_term")[:value]).to be_nil
    expect(find_field("sort_by")[:value]).to eq "created_at_desc"
  end
end
