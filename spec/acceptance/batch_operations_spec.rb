require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Batch operations on media entries in a set", %q{
  People want to apply some actions to multiple media entries at the same time so they
  avoid clicking around a lot.
} do

  # Ported to Cucumber
  background do
    set_up_world

    helmut = create_user("Helmut Kohl", "helmi", "schweinsmagen")
    log_in_as("helmi", "schweinsmagen")
    upload_some_picture("Picture One")
    upload_some_picture("Picture Two")
    upload_some_picture("Picture Three")
  end

  # Ported to Cucumber
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
    click_link_or_button("Aus Set entfernen")
    
    visit "/media_entries"
    click_media_entry_titled("Picture Three")
    click_link("Set One")

    # The two pictures we just removed shouldn't be on this
    # set's page anymore
    page.should_not have_content("Picture One")
    page.should_not have_content("Picture Two")
  end


  # Ported to Cucumber
  scenario "Change metadata on two media entries using batch edit", :js => true do
    user = log_in_as("helmi", "schweinsmagen")

    create_set("Batch Retitle Set")
    add_to_set("Batch Retitle Set", "Picture One")
    add_to_set("Batch Retitle Set", "Picture Two")

    visit "/media_entries"
    click_media_entry_titled("Picture One")
    click_link("Batch Retitle Set")

    check_media_entry_titled("Picture One")
    check_media_entry_titled("Picture Two")
    click_link_or_button("Metadaten editieren")

    fill_in_for_batch_editor( { "Titel" => "We are all individuals"} )

    click_button("Speichern")
    page.should have_content("Die Änderungen wurden gespeichert.")
    # They should both have the same title
    # TODO: Check for _two_ matches to this title
    page.should have_content("We are all individuals")

    sphinx_reindex
    visit "/media_entries"
    click_media_entry_titled("We are all individuals")
    page.should have_content("We are all individuals")

  end

end