require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Admin Meta Keys" do
  background { sign_in_as "adam" }

  scenario "Creating a new meta key" do
    visit "/app_admin/meta_keys"

    expect(page).to have_link("New Meta Key")
    click_link "New Meta Key"
    expect(current_path).to eq("/app_admin/meta_keys/new")
    fill_in "meta_key[id]", with: "test_meta_key"
    select "MetaDatumPeople", from: "meta_key[meta_datum_object_type]"
    click_button "Submit"

    expect(page).to have_css(".alert-success")
    expect{ MetaKey.find("test_meta_key") }.not_to raise_error
  end

  scenario "Listing meta keys with proper details" do
    visit "/app_admin/meta_keys"

    expect(page).to have_css("th", text: "Meta datum object type")
    expect(page).to have_css("th", text: "Amount of resources")
    expect(page).to have_css("th", text: "Contexts")
  end

  scenario "Filtering meta keys by label" do
    visit "/app_admin/meta_keys"

    expect(find_field("filter[label]")[:value]).to be_nil
    fill_in "filter[label]", with: "identifier"
    click_button "Apply"
    expect_results_containing("identifier")
    expect(find_field("filter[label]")[:value]).to eq("identifier")

    fill_in "filter[label]", with: "IDenTiFIER"
    click_button "Apply"
    expect_results_containing("identifier")

    fill_in "filter[label]", with: " IDenTiFIER  "
    click_button "Apply"
    expect_results_containing("identifier")
  end

  scenario "Filtering meta keys by label related to a context" do
    visit "/app_admin/meta_keys"

    fill_in "filter[label]", with: "Untertitel"
    click_button "Apply"
    expect_results_containing("Untertitel")
    expect_results_containing("subtitle")
  end

  scenario "Filtering meta keys by their types" do
    visit "/app_admin/meta_keys"

    expect(find_field("filter[meta_datum_object_type]")[:value]).to eq("")
    select "MetaDatumPeople", from: "filter[meta_datum_object_type]"
    click_button "Apply"
    expect_results_containing("MetaDatumPeople")
    expect(find_field("filter[meta_datum_object_type]")[:value]).to eq("MetaDatumPeople")
  end

  scenario "Filtering meta keys by context" do
    visit "/app_admin/meta_keys"

    expect(find_field("filter[context]")[:value]).to eq("")
    select "Core", from: "filter[context]"
    click_button "Apply"
    expect_results_containing("Core")
    expect(find_field("filter[context]")[:value]).to eq("Core")
  end

  scenario "Filtering meta keys by used (not used) status" do
    visit "/app_admin/meta_keys"

    expect(find_field("filter[is_used]")[:value]).to eq("")
    select "Not used", from: "filter[is_used]"
    click_button "Apply"
    expect_results_containing("Not used")
    expect(find_field("filter[is_used]")[:value]).to eq("false")
  end

  scenario "Deleting not used meta key" do
    visit "/app_admin/meta_keys?filter[is_used]=false"

    initial_count = MetaKey.count
    expect{ first("a", text: "Delete").click }.to change { MetaKey.count }.by(-1)
    expect(page).to have_css(".alert-success")
  end

  scenario "Adding a meta term with aplhabetical order" do
    visit "/app_admin/meta_keys/type/edit"

    expect(find_field("meta_key[meta_terms_alphabetical_order]")[:value]).to eq("true")
    within ".new-term" do
      fill_in "Term", with: "A"
    end
    click_button "Submit"
    expect(page).to have_css(".alert-success")
    expect(all("#sortable li[data-term]")).to start_with(find("li[data-term='A']"))
  end

  scenario "Adding a meta term with thematic order" do
    visit "/app_admin/meta_keys/type/edit"

    select "thematic order", from: "meta_key[meta_terms_alphabetical_order]"
    within ".new-term" do
      fill_in "Term", with: "A"
    end
    click_button "Submit"
    expect(page).to have_css(".alert-success")
    expect(all("#sortable li[data-term]")).to end_with(find("li[data-term='A']"))
  end

  scenario "Applying alphabetical order to meta terms" do
    visit "/app_admin/meta_keys/type/edit"

    select "thematic order", from: "meta_key[meta_terms_alphabetical_order]"
    within ".new-term" do
      fill_in "Term", with: "A"
    end
    click_button "Submit"

    select "alphabetical order", from: "meta_key[meta_terms_alphabetical_order]"
    click_button "Submit"

    expect(all("#sortable li[data-term]")).to start_with(find("li[data-term='A']"))
  end

  scenario "Merging a meta term to another one" do
    visit "/app_admin/meta_keys/LV_Wetter@Klima/edit"

    within "ul.meta-terms" do
      expect(page).to have_css("input[value='Gewitter']")
      expect(page).to have_css("input[value='Morgenrot']")
    end

    originator    = find("ul.meta-terms input[value='Gewitter']")
    originator_li = originator.find(:xpath, "ancestor::li")
    receiver      = find("ul.meta-terms input[value='Morgenrot']")
    receiver_li   = receiver.find(:xpath, "ancestor::li")

    fill_in "reassign_term_id[#{originator_li[:id]}]", with: receiver_li[:id]
    click_button "Submit"

    within "ul.meta-terms" do
      expect(page).not_to have_css("input[value='Gewitter']")
      expect(page).to have_css("input[value='Morgenrot']")
    end
  end

  scenario "Merging a meta term by giving an id with whitespaces" do
    visit "/app_admin/meta_keys/type/edit"

    fill_in "reassign_term_id[9a51b344-ce70-420d-8f16-9974b6afdb4c]", with: " 6b443b98-4297-499e-9964-4492f0be41ee  "
    click_button "Submit"
    expect(page).to have_css(".alert-success")
  end

  scenario "Changing type from MetaDatumString to MetaDatumMetaTerms" do
    visit "/app_admin/meta_keys/subtitle/edit"

    expect(find("select[name='meta_key[meta_datum_object_type]']", visible: false)[:value]).to eq("MetaDatumString")

    meta_key      = MetaKey.find('subtitle')
    meta_data     = meta_key.meta_data.to_a
    media_entries = meta_key.media_entries.to_a

    expect(meta_key.meta_datum_object_type).to eq("MetaDatumString")
    meta_data.each do |mt|
      expect(mt.type).to eq("MetaDatumString")
    end
    expect(meta_key.meta_terms.count).to eq(0)

    click_link "Change type to the MetaDatumMetaTerms"

    expect(meta_key.reload.meta_datum_object_type).to eq("MetaDatumMetaTerms")
    expect(media_entries.length).to eq(meta_key.reload.media_entries.count)
    meta_key.reload.meta_data do |mt|
      expect(mt.type).to eq("MetaDatumMetaTerms")
      expect(mt.string).to be_empty
    end
    meta_data.each do |mt|
      meta_term = MetaTerm.find_by(term: mt.string)
      
      expect(meta_key.reload.meta_terms.where(term: mt.string).count).to eq(1)
      expect(MetaDatumMetaTerms.find(mt.id).meta_terms.pluck(:id)) \
        .to include(meta_term.id)
    end

    expect(current_path).to eq("/app_admin/meta_keys/subtitle/edit")
    expect(page).to have_css(".alert-success")
    expect(page).to have_css("label", text: "Terms")
    expect(find_field("meta_key[meta_terms_alphabetical_order]")[:value]).to eq("true")
  end

  scenario "Displaying links to related contexts" do
    visit "/app_admin/meta_keys"

    expect(all("table tbody tr .context-link").size).to be > 0

    context_link = first(".context-link")
    context = Context.find_by(label: context_link.text)
    context_link.click
    expect(current_path).to eq(edit_app_admin_context_path(context))
  end

  def expect_results_containing(text)
    expect(all("table tbody tr", text: text).count).to eq(all("table tbody tr").count)
  end
end
