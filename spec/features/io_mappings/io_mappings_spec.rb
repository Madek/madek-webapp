require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Io Mappings" do

  before(:each) do
    @current_user = sign_in_as 'adam'
  end

  scenario "Creating an Io Mapping", browser: :headless do
    visit "/app_admin/io_mappings"

    click_on_text "New Io Mapping"

    find_input_with_name("io_mapping[key_map]").set("AWESOME NEW IO MAPPING")
    find_input_with_name("io_mapping[key_map_type]").set("AWESOME NEW TYPE")
    select("tms", from: "io_mapping[io_interface_id]")
    select("unknown kgit", from: "io_mapping[meta_key_id]")

    submit_form

    find(".alert-success", text: "created")
    find("tr", text: "AWESOME NEW IO MAPPING")
    find("tr", text: "AWESOME NEW TYPE")

  end

  scenario "Update an existing Io Mapping", browser: :headless do
    visit "/app_admin/io_mappings"

    click_on_text "Edit"

    find_input_with_name("io_mapping[key_map]").set("AWESOME EDITED IO MAPPING")
    find_input_with_name("io_mapping[key_map_type]").set("AWESOME EDITED TYPE")
    expect(page).not_to have_select('io_mapping_id')
    expect(page).not_to have_select('meta_key_id')

    submit_form

    find(".alert-success", text: "update")
    find("tr", text: "AWESOME EDITED IO MAPPING")
    find("tr", text: "AWESOME EDITED TYPE")

  end

  scenario "Deleting an existing Io Mapping", browser: :headless do
    visit "/app_admin/io_mappings"

    all_mappings_count = IoMapping.all.count

    click_on_text "Delete"

    find(".alert-success", text: "deleted")
    current_path.should == "/app_admin/io_mappings"
    IoMapping.all.count.should == all_mappings_count - 1
  end

  scenario "Filtering index results", browser: :headless do
    visit "/app_admin/io_mappings"
    find("#counter").text.should == IoMapping.all.count.to_s

    #filter with key_map
    find_input_with_name("filter[search_key_map]").set("Track2:BitDepth")
    
    submit_form

    find("#counter").text.should == "2"

    #filter with io interface
    select "default", from: "filter[io_interface]"

    submit_form

    find("#counter").text.should == IoMapping.where(io_interface_id: "default").count.to_s

    #filter with meta key
    select "title", from: "filter[meta_key]"

    submit_form
    
    find("#counter").text.should == IoMapping.where(meta_key_id: "title").count.to_s
  end
end
