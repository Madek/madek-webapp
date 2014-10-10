require 'rails_helper'
require 'spec_helper_feature_shared'

require Rails.root.join "spec","features","filter","shared.rb"
include Features::Filter::Shared

feature "Filter MediaResource Types" do

  scenario "Filter a list of resources by type", browser: :headless do

    visit media_resources_path

    open_filter

    check_filter_by_the_type_of_media_resources

  end

  def check_filter_by_the_type_of_media_resources
    find("[data-context-id='media_resources']").click
    find("[data-key-name='type']").click

    # MediaEntry
    find("[data-value='MediaEntry']").click
    expect(page).to have_selector(".ui-resource[data-id]")
    expect(all(".ui-resource[data-id]").size == all(".ui-resource[data-id][data-type='media-entry']").size).to be true
    find("[data-value='MediaEntry']").click

    # MediaSet
    find("[data-value='MediaSet']").click
    expect(page).to have_selector(".ui-resource[data-id]")
    expect(all(".ui-resource[data-id]").size == all(".ui-resource[data-id][data-type='media-set']").size).to be true
    find("[data-value='MediaSet']").click

    # FilterSet
    find("[data-value='FilterSet']").click
    expect(page).to have_selector(".ui-resource[data-id]")
    expect(all(".ui-resource[data-id]").size == all(".ui-resource[data-id][data-type='filter-set']").size).to be true
    find("[data-value='FilterSet']").click
end

end
