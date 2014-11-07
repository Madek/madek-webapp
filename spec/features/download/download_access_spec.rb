require "spec_helper"
require "spec_helper_feature"
require "spec_helper_feature_shared"

feature "Download - Access", browser: :headless do
  context "Owner" do
    before :each do
      @current_user = sign_in_as "adam"
      begin 
        @media_entry = FactoryGirl
          .create :media_entry_with_large_image_media_file, user: @current_user
      end until @media_entry.media_file.previews.where(thumbnail: "x_large").present?
    end

    scenario "Download should be accessible for owner" do
      visit media_entry_path(@media_entry)
      click_on_text "Weitere Aktionen"
      click_on_text "Exportieren"
      click_on_text "Datei mit aktuellen Metadaten"
      within("#with-latest-meta-data") do
        @download = find(".ui-drop-item:nth-child(2) a")['href']
      end
      expect(@download.last(12)).to eq "size=x_large"
      visit @download
      expect(page.response_headers['Content-Type']).to eq "image/jpeg"
    end

    scenario "Download of the original file should be accessible for owner" do
      visit media_entry_path(@media_entry)
      click_on_text "Weitere Aktionen"
      click_on_text "Exportieren"
      click_on_text "Datei mit aktuellen Metadaten"
      within("#with-latest-meta-data") do
        @download = first(".ui-drop-item:first-child a")['href']
      end
      expect(@download.last(12)).not_to eq "size=x_large"
      visit @download
      expect(page.response_headers['Content-Type']).to eq "image/jpeg"
    end
  end

  context "User" do
    before :each do
      @current_user = sign_in_as "adam"
      begin
        @media_entry = FactoryGirl
          .create :media_entry_with_large_image_media_file, user: User.last
      end until @media_entry.media_file.previews.where(thumbnail: "x_large").present?
    end

    scenario "Download should be accessible for entries with view userpermission" do
      Userpermission.create(user: @current_user, media_resource: @media_entry, view: true)
      visit media_entry_path(@media_entry)
      click_on_text "Weitere Aktionen"
      click_on_text "Exportieren"
      click_on_text "Datei mit aktuellen Metadaten"
      within("#with-latest-meta-data") do
        @download = first(".ui-drop-item:first-child a")['href']
      end
      expect(@download.last(12)).to eq "size=x_large"
      visit @download
      expect(page.response_headers['Content-Type']).to eq "image/jpeg"
    end

    scenario "Download of the original file should be accessible for entries with download userpermission" do
      Userpermission.create(user: @current_user, media_resource: @media_entry, view: true, download: true)
      visit media_entry_path(@media_entry)
      click_on_text "Weitere Aktionen"
      click_on_text "Exportieren"
      click_on_text "Datei mit aktuellen Metadaten"
      within("#with-latest-meta-data") do
        @download = first(".ui-drop-item:first-child a")['href']
      end
      expect(@download.last(12)).not_to eq "size=x_large"
      visit @download
      expect(page.response_headers['Content-Type']).to eq "image/jpeg"
    end

    scenario "Download of the original file should be inaccessible for entries without permissions" do
      visit "/download#{@media_entry.id}&update=1"
      expect(page.response_headers['Content-Type']).not_to eq "image/jpeg"
    end
  end

  context "Guest" do
    before :each do
      begin
        @media_entry = FactoryGirl
          .create :media_entry_with_large_image_media_file
      end until @media_entry.media_file.previews.where(thumbnail: "x_large").present?
    end

    scenario "Download should be accessible for entries with view permission" do
      @media_entry.update_column(:view, true)
      visit media_entry_path(@media_entry)
      click_on_text "Weitere Aktionen"
      click_on_text "Exportieren"
      click_on_text "Datei mit aktuellen Metadaten"
      within("#with-latest-meta-data") do
        @download = first(".ui-drop-item:first-child a")['href']
      end
      expect(@download.last(12)).to eq "size=x_large"
      visit @download
      expect(page.response_headers['Content-Type']).to eq "image/jpeg"
    end

    scenario "Download of the original file should be accessible for entries with download permission" do
      @media_entry.update_attribute(:view, true)
      @media_entry.update_attribute(:download, true)
      visit media_entry_path(@media_entry)
      click_on_text "Weitere Aktionen"
      click_on_text "Exportieren"
      click_on_text "Datei mit aktuellen Metadaten"
      within("#with-latest-meta-data") do
        @download = first(".ui-drop-item:first-child a")['href']
      end
      expect(@download.last(12)).not_to eq "size=x_large"
      visit @download
      expect(page.response_headers['Content-Type']).to eq "image/jpeg"
    end

    scenario "Download of the original file should be inaccessible for entries without permissions" do
      visit "/download#{@media_entry.id}&update=1"
      expect(page.response_headers['Content-Type']).not_to eq "image/jpeg"
    end
  end
end
