require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Manage media entries", %q{
  People want to upload images and add information.
} do


  background do
    set_up_world
    helmut = create_user("Helmut Kohl", "helmi", "schweinsmagen")
    gorbatschow = create_user("Mikhail Gorbachev", "gorbi", "glasnost")
  end

  scenario "Upload one image file without any special metadata", :js => true do
    upload_some_picture(title = "not a special picture")
  end

  scenario "Upload a media entry and add it to a set", :js => true do
    helmut = log_in_as("helmi", "schweinsmagen")
    helmut.media_entries.reload.count.should == 0
    visit homepage
    # The upload itself
    click_link("Hochladen")
    click_link("Basic Uploader")
    attach_file("uploaded_data[]", Rails.root + "spec/data/images/berlin_wall_01.jpg")
    click_button("Ausgewählte Medien hochladen »")
    wait_for_css_element("#submit_to_3") # This is the "Einstellungen speichern..." button
    click_button("Einstellungen speichern und weiter »")

    # Entering metadata
    fill_in_for_media_entry_number(1, { "Titel" => 'berlin wall for a set',
                                        "Copyright" => 'some other dude' })

    click_button("Metadaten speichern und weiter »")
    
    # "Medien gruppieren" screen
    click_button("Neu")
    # #text_media_set is the empty input field for the set name
    wait_for_css_element("#text_media_set")
    fill_in find("#text_media_set").find("input")[:id], :with => 'Mauerstücke'
    click_button("Hinzufügen")
    
    click_link_or_button("Gruppierungseinstellungen speichern")

    # Stuff that should be in the system
    helmut.media_entries.reload.count.should == 1
    helmut.media_sets.first.media_entries.reload.count.should == 1
    sphinx_reindex
    MediaEntry.search("berlin").total_entries.should > 0
    
    
    # Stuff I should be able to see with my eyes
    visit homepage


    # We look for the title of the image we uploaded because
    # we don't really have much use for more accurate tests right now
    page.should have_content("berlin wall for a set")

    
  end
  
  scenario "Upload an image file for another user to see", :js => true do
    
   # helmut uploads a piece of the berlin wall for gorbi to see
    helmut = log_in_as("helmi", "schweinsmagen")
    helmut.media_entries.reload.count.should == 0
    visit homepage
    # The upload itself
    click_link("Hochladen")
    click_link("Basic Uploader")
    attach_file("uploaded_data[]", Rails.root + "spec/data/images/berlin_wall_01.jpg")
    click_button("Ausgewählte Medien hochladen »")
    wait_for_css_element("#submit_to_3") # This is the "Einstellungen speichern..." button
    click_button("Einstellungen speichern und weiter »")

    # Entering metadata

    fill_in_for_media_entry_number(1, { "Titel" => 'A beautiful piece of the Berlin Wall',
                                        "Copyright" => 'Kohl, Helmut' })

    click_button("Metadaten speichern und weiter »")
    click_link_or_button("Weiter ohne Gruppierung")
    helmut.media_entries.reload.count.should == 1
    sphinx_reindex

    MediaEntry.search("berlin").total_entries.should > 0
    visit homepage
    
    click_media_entry_titled("A beautiful piece of the Berlin Wall")
    click_link("Zugriffsberechtigung")
    type_into_autocomplete(:user, 'Gorba')
    
    sleep(1)
    pick_from_autocomplete("Gorbachev, Mikhail")
    sleep(0.5)
    give_permission_to("view", to = "Gorbachev, Mikhail")
    sleep(2)

    click_on_arrow_next_to("Kohl, Helmut")
    click_link("Abmelden")
    gorbi = log_in_as("gorbi", "glasnost")

    visit homepage
    # Gorbi should see Helmut's image
    page.should have_content("A beautiful piece of the Berlin Wall")
    
  end

  scenario "Upload an image file for my group to see", :js => true do
    # bruce willis or chuck norris make a group 'wiedervereinigung' and
    # add helmut and gorbi to it. then helmut lets the group see
    # a set.
    

    # Bruce Willis needs to make the group for now, because Gorbi and Helmut don't
    # have any interaction they can use for that in the frontend yet
    group = create_group("Mauerfäller")
    # We have those two users already from the step before
    add_user_to_group(User.where(:login => 'helmi').first, group)
    add_user_to_group(User.where(:login => 'gorbi').first, group)
    group.users.count.should == 2

    helmut = log_in_as("helmi", "schweinsmagen")
    helmut.media_entries.reload.count.should == 0

    sphinx_reindex
    visit homepage
    # The upload itself
    click_link("Hochladen")
    click_link("Basic Uploader")
    attach_file("uploaded_data[]", Rails.root + "spec/data/images/berlin_wall_02.jpg")
    click_button("Ausgewählte Medien hochladen »")
    wait_for_css_element("#submit_to_3") # This is the "Einstellungen speichern..." button
    click_button("Einstellungen speichern und weiter »")

    # Entering metadata

    fill_in_for_media_entry_number(1, { "Titel" => 'A second piece of the Berlin Wall',
                                        "Copyright" => 'Kohl, Helmut' })

    click_button("Metadaten speichern und weiter »")
    click_link_or_button("Weiter ohne Gruppierung")
    helmut.media_entries.reload.count.should == 1

    sphinx_reindex
    MediaEntry.search("berlin").total_entries.should > 0

    visit homepage
    
    click_media_entry_titled("A second piece of the Berlin Wall")
    click_link("Zugriffsberechtigung")
    type_into_autocomplete(:group, 'Mauer')
    sleep(1)

    pick_from_autocomplete("Mauerfäller")
    sleep(0.5)
    give_permission_to("view", to = "Mauerfäller")
    sleep(2)

    click_on_arrow_next_to("Kohl, Helmut")
    click_link("Abmelden")
    gorbi = log_in_as("gorbi", "glasnost")

    page.should have_content("A second piece of the Berlin Wall")

    sphinx_reindex
    # And this is how it really should be, let's let this fail until there's a solution
    visit homepage

    # Gorbi should see Helmut's image
    page.should have_content("A second piece of the Berlin Wall")
    
  end

  scenario "Make an uploaded file public", :js => true do
    # Helmut wants the world to see pieces of the wall
    # Can't do this yet, because we don't have a notion of "public" yet
    # since we always force logins.
    user = log_in_as("helmi", "schweinsmagen")
    upload_some_picture(title = "baustelle osten")
    visit homepage
    click_media_entry_titled("baustelle osten")
    click_link("Zugriffsberechtigung")
    wait_for_css_element("table.permissions")
    give_permission_to("view", to = :everybody)


    raissa= create_user("Raissa Gorbacheva", "raissa", "novodevichy")
    user = log_in_as("raissa", "novodevichy")
    visit homepage
    page.should have_content("baustelle osten")


  end


  scenario "Upload a public file and then make it un-public again", :js => true do

    user = log_in_as("helmi", "schweinsmagen")
    upload_some_picture(title = "geheimsache")
    visit homepage
    click_media_entry_titled("geheimsache")
    click_link("Zugriffsberechtigung")
    wait_for_css_element("table.permissions")
    give_permission_to("view", to = :everybody)

    # This is public, Mikhail's wife should be able to see it, too
    raissa= create_user("Raissa Gorbacheva", "raissa", "novodevichy")
    user = log_in_as("raissa", "novodevichy")
    visit homepage
    page.should have_content("geheimsache")

    # Mikhail makes it a secret
    user = log_in_as("helmi", "schweinsmagen")
    click_media_entry_titled("geheimsache")
    click_link("Zugriffsberechtigung")
    remove_permission_to("view", from = :everybody)

    sphinx_reindex
    # The secret is gone! His wife can no longer see it because
    # she's not in any group that has view permission on this entry,
    # and the entry is no longer public
    user = log_in_as("raissa", "novodevichy")
    visit homepage
    page.should_not have_content("geheimsache")
  end

  scenario "Give hi-resolution download permission on a file", :js => true do
    create_user("Hans Wurst", "hanswurst", "hansi")
    
    user = log_in_as("helmi", "schweinsmagen")
    upload_some_picture(title = "hochaufgelöste geheimbünde")
    visit homepage
    click_media_entry_titled("hochaufgelöste geheimbünde")
    click_link("Zugriffsberechtigung")
    type_into_autocomplete(:user, 'Wurs')
    sleep(5)
    pick_from_autocomplete("Wurst, Hans")
    give_permission_to("view", to = "Wurst, Hans")
    give_permission_to("download_hires", to = "Wurst, Hans")

    hanswurst = log_in_as("hanswurst","hansi")
    visit homepage
    click_media_entry_titled("hochaufgelöste geheimbünde")
    click_link("Download")

    # If there is one <a> anywhere inside the first download-unit row,
    # that <a> is the download button for the full resolution. If it wouldn't
    # be there, the _next_ row would contain a download button instead, and that
    # one would be linked to the lo-res version.
    find(:css, "tr.download-unit").all("a").count.should == 1
    
    # page should have both hi- and lo-res download buttons

  end


  scenario "Give and then revoke hi-resolution download permission on a file", :js => true do
    create_user("Hans Wurst", "hanswurst", "hansi")

    user = log_in_as("helmi", "schweinsmagen")
    upload_some_picture(title = "hochaufgelöste geheimbünde")
    visit homepage
    click_media_entry_titled("hochaufgelöste geheimbünde")
    click_link("Zugriffsberechtigung")
    type_into_autocomplete(:user, 'Wurs')
    sleep(5)
    pick_from_autocomplete("Wurst, Hans")
    give_permission_to("view", to = "Wurst, Hans")
    give_permission_to("download_hires", to = "Wurst, Hans")

    # Log in as Hans Wurst to see if he can download the hi-res version
    hanswurst = log_in_as("hanswurst","hansi")
    visit homepage
    click_media_entry_titled("hochaufgelöste geheimbünde")
    click_link("Download")

    # If there is one <a> anywhere inside the first download-unit row,
    # that <a> is the download button for the full resolution. If it wouldn't
    # be there, the _next_ row would contain a download button instead, and that
    # one would be linked to the lo-res version.
    find(:css, "tr.download-unit").all("a").count.should == 1

    # Now let's revoke those permissions again
    user = log_in_as("helmi", "schweinsmagen")
    click_media_entry_titled("hochaufgelöste geheimbünde")
    click_link("Zugriffsberechtigung")
    remove_permission_to("download_hires", from = "Wurst, Hans")

    # And Hans shouldn't be able to download the hi-res version anymore
    hanswurst = log_in_as("hanswurst","hansi")
    click_media_entry_titled("hochaufgelöste geheimbünde")
    find(:css, "tr.download-unit").all("a").count.should == 0


  end
  
end
