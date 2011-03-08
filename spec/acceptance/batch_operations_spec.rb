require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Batch operations on media entries in a set", %q{
  People want to apply some actions to multiple media entries at the same time so they
  avoid clicking around a lot.
} do


  background do
    set_up_world

    helmut = create_user("Helmut Kohl", "helmi", "schweinsmagen")
    log_in_as("helmi", "schweinsmagen")
    upload_some_picture("Picture One")
     upload_some_picture("Picture Two")
     upload_some_picture("Picture Three")
  end
  
  scenario "Remove two media entries from a set using batch edit", :js => true do
    user = log_in_as("helmi", "schweinsmagen")

    create_set("Set One")
    add_to_set("Set One", "Picture One")
    add_to_set("Set One", "Picture Two")
    add_to_set("Set One", "Picture Three")

    visit "/media_entries"
    click_media_entry_titled("Picture One")
    click_link("Set One")

    check_media_entry_titled("Picture One")
    check_media_entry_titled("Picture Two")
    check_media_entry_titled("Picture Three")

    # TODO: When Capybara finally supports hovering over items or
    # checking invisible checkboxes, we need to check them and then
    # continue here.
    
  end

  scenario "Add two media entries to favorites using batch edit" do


  end

end