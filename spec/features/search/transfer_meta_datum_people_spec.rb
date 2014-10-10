require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Transfering PersonMetaData and search"  do


  scenario "Searching for a Person X name shows related media entries. 
          Transfering all PersonMetaData from person X to person Y.
          Searching for Person X doesn't show the media entries as before.
          Searching for Person Y does show the media entries as before.",
          browser: :headless do

    @current_user= sign_in_as 'adam'

    @media_entry= create_a_media_entry

    @personX= Person.create first_name: 'Xaver', last_name: "Unsinn" 
    @personY= Person.create first_name: 'Yolanda', last_name: "Foster"

    set_media_resource_title @media_entry, "Schnarchnase"
    set_media_resource_authors @media_entry, [@personX]
    @media_entry.reindex

    click_on_text "Suche"
    find_input_with_name("terms").set("Unsinn")
    submit_form
    expect(page).to have_content "Xaver"
    expect(page).to have_content "Schnarchnase"
    click_on_text "Adam Admin"
    click_on_text "Admin-Interface"
    click_on_text "Users & Groups"
    click_on_text "People"
    find_input_with_name("filter[search_terms]").set("Xaver")
    submit_form
    expect(page).to have_content "Xaver"
    click_on_text("transfer")
    find_input_with_name("[id_receiver]").set(@personY.id)
    submit_form
    find(".alert-success",text: "transferred")

    visit("/search")
    find_input_with_name("terms").set("Unsinn")
    submit_form
    expect(page).not_to have_content "Xaver"
    expect(page).not_to have_content "Schnarchnase"

    visit("/search")
    find_input_with_name("terms").set("Yolanda")
    submit_form
    expect(page).to have_content "Schnarchnase"

  end


  require Rails.root.join "spec","features","search","shared.rb"
  include Features::Search::Shared

  def set_media_resource_authors media_resource, authors
    media_resource.meta_data \
      .create meta_key: MetaKey.find_by_id(:author), value: authors
  end


end


