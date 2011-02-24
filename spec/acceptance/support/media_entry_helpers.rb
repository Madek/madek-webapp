def upload_some_picture(title = nil, user = nil)
    user ||= log_in_as("helmi", "schweinsmagen")
    start_count = user.media_entries.count
    
    visit homepage
    # The upload itself
    click_link("Hochladen")
    click_link("Basic Uploader")
    attach_file("uploaded_data[]", Rails.root + "spec/data/images/berlin_wall_01.jpg")
    click_button("Ausgewählte Medien hochladen »")
    wait_for_css_element("#submit_to_3") # This is the "Einstellungen speichern..." button
    click_button("Einstellungen speichern und weiter »")

    # Entering metadata

    fill_in_for_media_entry_number(1, { "Titel"     => title,
                                        "Copyright" => 'some dude' })

    click_button("Metadaten speichern und weiter »")
    click_link_or_button("Weiter ohne Gruppierung")
    user.media_entries.reload.count.should == start_count + 1

    sphinx_reindex
    visit homepage

    #debugger
    MediaEntry.search(title).total_entries.should > 0
    page.should have_content(title)

end