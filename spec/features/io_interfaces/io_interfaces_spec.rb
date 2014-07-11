require "spec_helper"
require "spec_helper_feature"
require "spec_helper_feature_shared"

feature "Io Interfaces" do

  before(:each) do
    @current_user = sign_in_as 'adam'
  end

  scenario "Creating an Io Interface", browser: :headless do
    visit "/app_admin/io_interfaces"

    click_on_text "New Io Interface"

    find_input_with_name("io_interface[id]").set("AWESOME NEW IO INTERFACE")
    find_input_with_name("io_interface[description").set("AWESOME NEW DESCRIPTION")

    submit_form

    find(".alert-success", text: "created")
    find("td", text: "AWESOME NEW IO INTERFACE")
    find("td", text: "AWESOME NEW DESCRIPTION")

  end

  scenario "Deleting an existing Io Interface", browser: :headless do
    visit "/app_admin/io_interfaces"

    all_interfaces_count = IoInterface.all.count

    within("tr#default") do
      click_on_text "Delete"
    end

    find(".alert-success", text: "deleted")
    current_path.should == "/app_admin/io_interfaces"

    IoInterface.all.count == all_interfaces_count - 1
    IoMapping.where(io_interface_id: "default").count == 0
  end

  scenario "Using io mappings link", browser: :headless do
    visit "/app_admin/io_interfaces"
    click_on_text "Io Mappings"

    find("#counter").text.should == IoMapping.where(io_interface_id: "default").count.to_s
  end
end
