require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Admin Previews" do
  background { @admin = sign_in_as "adam" }

  scenario "Regenerating previews for still images (JPEG, TIFF...)" do
    media_entry = FactoryGirl.create(:media_entry_with_image_media_file, user: @admin)
    media_entry.media_file.previews.destroy_all

    visit media_entry_path(media_entry)
    click_link "Weitere Aktionen"
    click_link "MediaEntry in the Admin Interface"
    click_link "Media-File:"

    expect(page).to have_css("table.previews tbody")
    expect(all("table.previews tbody tr").size).to eq 0

    click_link "Recreate Thumbnails"
    expect(all("table.previews tbody tr").size).to be > 1
  end

  scenario "Reencode previews for audio/video" do
    Settings.add_source! (Rails.root.join "spec","data","zencoder.yml").to_s
    Settings.reload!
    media_entry = 
      (FactoryGirl.create :media_entry_incomplete_for_movie, user: @admin).set_as_complete

    visit media_entry_path(media_entry)
    click_link "Weitere Aktionen"
    click_link "MediaEntry in the Admin Interface"
    click_link "Media-File:"

    zencoder_jobs_count = all("table.zencoder-jobs tbody tr").size rescue 0
    click_link "Reencode"
    expect(all("table.zencoder-jobs tbody tr").size).to eq(zencoder_jobs_count + 1)
    expect(first("table.zencoder-jobs tbody tr td.state").text).to eq("submitted")
  end
end
