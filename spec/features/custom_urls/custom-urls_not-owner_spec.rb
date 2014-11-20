require "spec_helper"
require "spec_helper_feature"
require 'spec_helper_feature_shared'

feature "View and manage custom urls for users not being the owner " do 

  scenario "A user with view permission can see custom urls", 
    browser: :headless do

    @creator = User.find_by login:  "petra"

    @viewer = sign_in_as 'normin'

    @media_entry= FactoryGirl.create :media_entry_with_image_media_file, user: @creator

    @custom_url = CustomUrl.create! id: "the-custom-url", media_resource: @media_entry, creator: @creator, updator: @creator

    Userpermission.create! media_resource: @media_entry, user: @viewer, view: true

    visit media_entry_path(@media_entry)

    click_on_text "Weitere Aktionen"

    click_on_text "Adressen"

    expect(page).to have_content "the-custom-url"

  end

  scenario "A user with manage permission can set a custom url as primary", 
    browser: :headless do

    @creator = User.find_by login:  "petra"

    @manager = sign_in_as 'normin'

    @media_entry= FactoryGirl.create :media_entry_with_image_media_file, user: @creator

    @custom_url = CustomUrl.create! id: "the-custom-url", media_resource: @media_entry, creator: @creator, updator: @creator

    Userpermission.create! media_resource: @media_entry, user: @manager, view: true, manage: true

    visit media_entry_path(@media_entry)

    click_on_text "Weitere Aktionen"

    click_on_text "Adressen"

    expect(page).to have_content "the-custom-url"

    expect(page).to have_content "Aktionen"

    # The "the-custom-url" is not the primary url
    expect(all("tr.custom-url#the-custom-url td.type", text: "Primäre Adresse")).to be_empty

    click_on_text "Als primäre Adresse setzen"

    # The "the-custom-url" is now the primary url
    find("tr.custom-url#the-custom-url td.type", text: "Primäre Adresse")

  end


  scenario "A user with manage permission can add a custom url", 
    browser: :headless do

    @creator = User.find_by login:  "petra"

    @manager = sign_in_as 'normin'

    @media_entry= FactoryGirl.create :media_entry_with_image_media_file, user: @creator

    Userpermission.create! media_resource: @media_entry, user: @manager, view: true, manage: true

    visit media_entry_path(@media_entry)

    click_on_text "Weitere Aktionen"

    click_on_text "Adressen"

    click_on_text "Adresse anlegen"

    find("input").set "the-new-custom-url"

    submit_form 

    expect(page).to have_content("the-new-custom-url")

  end


end
