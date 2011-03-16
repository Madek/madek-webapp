# Uploads a picture with a given title and a fixed copyright string.
# It's always the same picture, no way to change the image file yet.
def upload_some_picture(title = "Untitled")

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

    sphinx_reindex
    visit homepage

    page.should have_content(title)

end

# Creates a new set
def create_set(set_title = "Untitled Set")
  visit "/media_sets"
  fill_in "media_set_meta_data_attributes_0_value", :with => set_title
  click_link_or_button "Erstellen"
end

# Adds a media entry to a set. Only works if the media entry
# has a title, so that it shows up under /media_entries. The set
# also needs a title.
def add_to_set(set_title = "Untitled Set", picture_title = "Untitled")
  visit "/media_entries"
  click_media_entry_titled(picture_title)
  click_link_or_button("Gruppieren")
  select(set_title, :from => "media_set_ids[]")
  click_link_or_button("Gruppierungseinstellungen speichern")
  # The set title is displayed on the right-hand side of this page, so we should be able to
  # see it here.
  page.should have_content(set_title)
end