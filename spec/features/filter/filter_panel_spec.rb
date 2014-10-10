require 'rails_helper'
require 'spec_helper_feature_shared'

require Rails.root.join "spec","features","filter","shared.rb"
include Features::Filter::Shared

feature "Filter panel" do

  scenario "Filter by 'any' value", browser: :firefox do

    visit media_resources_path

    open_filter

    select_any_value_checkbox_for_specific_key

    assert_resources_with_any_value_key

  end

  scenario "Existence of the filter-panel and searching for an empty term", browser: :headless do

    sign_in_as "Liselotte"

    click_on_text "Suche"

    assert_exact_url_path "/search"

    submit_form

    find(".filter-panel")

    within ".filter-panel" do
      find(".filter-search")
      find("ul.top-filter-list")
      assert_top_filter "Inhalte"
      assert_top_filter "Datei"
      assert_top_filter "Berechtigung"
      assert_top_filter "Werk"
      assert_top_filter "Landschaftsvisualisierung"
      assert_top_filter "Medium"
      assert_top_filter "Säulenordnung"
      assert_top_filter "ZHdK"
      assert_top_filter "Lehrmittel Fotografie"
    end

  end

  scenario "Filter by free text search term", browser: :firefox do

    sign_in_as "Liselotte"

    visit media_resources_path(filterpanel: true)

    resources_counter = get_number_of_resources

    fill_in "search", with: "Landschaft"

    expect(page).to have_selector ".ui-resource"

    expect(get_number_of_resources).to be < resources_counter

  end

  scenario "Filter by file", browser: :headless do

    sign_in_as "Liselotte"

    visit media_resources_path(filterpanel: true)

    click_on_text "Datei"

    click_on_text "Medientyp"

    check_link_filter "image"

  end

  scenario "Filter by permissions with multiple filters", browser: :headless do

    sign_in_as "Liselotte"

    visit media_resources_path(filterpanel: true)

    click_on_text "Berechtigung"

    click_on_text "Zugriff"

    check_link_filter "Öffentliche Inhalte"

    click_on_text "Verantwortliche Person"

    check_link_filter "Knacknuss, Karen"

  end

  scenario "Filter by work", browser: :headless do

    sign_in_as "Liselotte"

    visit media_resources_path(filterpanel: true)

    click_on_text "Werk"

    click_on_text "Schlagworte zu Inhalt und Motiv"

    check_link_filter "Fotografie"

  end

  scenario "Filter by \"Landschaftsvisualisierung\" with multiple field filter", browser: :headless do

    sign_in_as "Liselotte"

    visit media_resources_path(filterpanel: true)

    click_on_text "Landschaftsvisualisierung"

    click_on_text "Stil- und Kunstrichtungen"

    check_link_filter "Konzeptkunst"

    check_link_filter "Reine Fotografie"

  end

  scenario "Filter by Medium", browser: :headless do

    sign_in_as "Liselotte"

    visit media_resources_path(filterpanel: true)

    click_on_text "Medium"

    click_on_text "Material/Format"

    check_link_filter "8-Kanal Audio"

  end

  scenario "Filter by \"Säulenordnungen\"", browser: :headless do

    sign_in_as "Liselotte"

    visit media_resources_path(filterpanel: true)

    click_on_text "Säulenordnungen"

    click_on_text "Stil- und Kunstrichtungen"

    check_link_filter "Konzeptkunst"

  end

  scenario "Filter by \"ZHdK\"", browser: :headless do

    sign_in_as "Liselotte"

    visit media_resources_path(filterpanel: true)

    click_on_text "ZHdK"

    click_on_text "ZHdK-Projekttyp"

    check_link_filter "Abschlussarbeit"

  end

  scenario "Filter by \"Lehrmittel Fotografie\"", browser: :headless do

    sign_in_as "Liselotte"

    visit media_resources_path(filterpanel: true)

    click_on_text "Lehrmittel Fotografie"

    click_on_text "Stil- und Kunstrichtungen"

    check_link_filter "Konzeptkunst"

  end

  scenario "Combining multiple filter from multiple groups: \"Datei\" and \"Berechtigung\"", browser: :headless do

    sign_in_as "Liselotte"

    visit media_resources_path(filterpanel: true)

    click_on_text "Datei"

    click_on_text "Dokumenttyp"

    check_link_filter "jpg"

    click_on_text "Berechtigung"

    click_on_text "Verantwortliche Person"

    check_link_filter "Knacknuss, Karen"

  end

  scenario "Resetting all filters", browser: :headless do

    sign_in_as "Liselotte"

    visit media_resources_path(filterpanel: true)

    click_on_text "Datei"

    click_on_text "Dokumenttyp"

    check_link_filter "jpg"

    click_on_text "Berechtigung"

    click_on_text "Verantwortliche Person"

    check_link_filter "Knacknuss, Karen"

    click_on_text "Filter zurücksetzen"

    resources_counter = get_number_of_resources

    visit media_resources_path(filterpanel: true)

    expect(page).to have_selector ".ui-resource"

    expect(get_number_of_resources).to eq resources_counter

  end

  scenario "Resetting single filters", browser: :headless do

    sign_in_as "Liselotte"

    visit media_resources_path(filterpanel: true)

    click_on_text "Datei"

    click_on_text "Dokumenttyp"

    check_link_filter "jpg"

    ########################

    click_on_text "Landschaftsvisualisierung"

    click_on_text "Stil- und Kunstrichtungen"

    check_link_filter "Konzeptkunst"

    ########################

    resources_counter = get_number_of_resources

    click_on_text "Konzeptkunst"

    expect(page).to have_selector ".ui-resource"

    expect(get_number_of_resources).not_to eq resources_counter

    ########################

    resources_counter = get_number_of_resources

    click_on_text "jpg"

    expect(page).to have_selector ".ui-resource"

    expect(get_number_of_resources).not_to eq resources_counter

    ########################

    resources_counter = get_number_of_resources

    visit media_resources_path(filterpanel: true)

    expect(get_number_of_resources).to eq resources_counter

  end

  def check_link_filter text
    filter_counter = get_count_for_filter text
    click_on_text text
    expect(page).to have_selector ".ui-resource"
    expect(get_number_of_resources).to eq filter_counter
  end

  def select_any_value_checkbox_for_specific_key
    expect(page).to have_selector(".any-value", visible: false)
    @any_value_el = all(".any-value", visible: false).sample
    context_id = @any_value_el.
      find(:xpath, "ancestor::*[@data-context-id]", visible: false)["data-context-id"]
    key_name = @any_value_el.
      find(:xpath, "ancestor::*[@data-key-name]", visible: false)["data-key-name"]
    @meta_key = MetaKey.find(key_name)
    @any_value_el.find(:xpath, "ancestor::*[@data-context-id]").find('a', match: :first).click
    @any_value_el.find(:xpath, "ancestor::label").click
    expect(page).to have_selector(".ui-resource")
  end

  def assert_resources_with_any_value_key
    all(".ui-resource[data-id]").each do |element|
      media_resource = MediaResource.find element["data-id"]
      expect(media_resource.meta_data.where(:meta_key_id => @meta_key.id).size).to be > 0
    end
  end

  def assert_top_filter text
    find("ul.top-filter-list", text: text)
  end

  def get_number_of_resources
    find("#ui-resources-list #resources_counter", match: :first).text.to_i
  end

  def get_count_for_filter filter
    find("li.resources_filter", text: filter).find(".resources_count").text.to_i
  end

end
