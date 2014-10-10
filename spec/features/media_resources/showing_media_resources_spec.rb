require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'Showing resources in the archive' do

  scenario 'Displaying resources in a FilterSet that includes all public entries', browser: :headless do

    @current_user = sign_in_as "normin"

    @filter_set = FilterSet.find "1717e608-9c99-4ae9-af77-e964b617a00c"
    visit filter_set_path(@filter_set)

    assert_minimal_amount_of_included_resources 3

    click_on_data_type "media_entries", text: "Medieneinträge"

    assert_minimal_amount_of_included_resources 3

    click_on_data_type "sets", text: "Sets"

    assert_minimal_amount_of_included_resources 3

  end

  scenario "Displaying resources in a MediaSet that inclues a Set, FilterSet and an Entry", browser: :headless do

    @current_user = sign_in_as "normin"

    @media_set = MediaSet.find "f54098a8-6ca1-492b-a2a0-b2330e5eb4bc"

    visit media_set_path(@media_set)

    assert_exact_amount_of_included_resources 3

    click_on_data_type "media_entries", text: "Medieneinträge"

    assert_exact_amount_of_included_resources 1

    click_on_data_type "sets", text: "Sets"

    assert_exact_amount_of_included_resources 2

  end

  scenario "Watching a movie as a guest", browser: :firefox do

    # There is a movie with previews and public viewing\-permission
    System.execute_cmd! "tar xf #{Rails.root.join "spec/data/media_files_with_movie.tar.gz"} -C #{Rails.root.join  "db/media_files/", Rails.env}"
    @movie = MediaFile.find_by(guid: "66b1ef50186645438c047179f54ec6e6").media_entry
    ###############################################################

    visit media_resource_path(@movie)

    # I can see the preview
    expect(find("img.vjs-poster")).to be

    # I can watch the video
    find(".vjs-big-play-button",visible: true).click()
    expect(page).not_to have_selector(".vjs-big-play-button",visible: true)
    sleep 10 # Capybara.default_wait_time = 2, that's why we have to wait more here
    expect(page).to have_selector(".vjs-big-play-button",visible: true)
    ###############################################################

  end

  scenario "Displaying parent sets" do

    @current_user = sign_in_as "normin"

    @media_resource = MediaResource.find "392d305c-a05b-48d0-86c1-0a42e14887c9"
    visit media_resource_path(@media_resource)

    click_on_text "Zusammenhänge"

    expect(page).to have_content "Public Set including"

  end

  def assert_minimal_amount_of_included_resources n
    expect(page).to have_selector "ul#ui-resources-list li.ui-resource"
    expect(all("ul#ui-resources-list li.ui-resource").size).to be >= n
  end

  def assert_exact_amount_of_included_resources n
    expect(page).to have_selector "ul#ui-resources-list li.ui-resource"
    expect(all("ul#ui-resources-list li.ui-resource").size).to be == n
  end

  def click_on_data_type value, text:
    find("a[data-type='#{value}'], button[data-type='#{value}']", text: text).click
  end

end
