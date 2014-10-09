require "spec_helper"
require "spec_helper_feature"
require "spec_helper_feature_shared"

feature "Error handling", browser: :headless do
  context "media entry" do
    before(:each) do
      @media_entry = FactoryGirl
        .create :media_entry_with_image_media_file
    end

    scenario "Accessing non exisitng media entry should give 404 error" do
      visit '/entries/ddf90877-4dd9-48e9-8cf1-b146ed7ebesd'
      error = first(".title-xxl").text
      expect(error).to eq "HTTP Fehler 404 - Nicht gefunden"
    end

    scenario "Accessing non-accessible media entry without being logged in should prompt for login" do
      visit media_entry_path(@media_entry)
      error = first(".ui-alert").text
      expect(error).to eq "Bitte melden Sie sich an."
      visit relations_media_entry_path(@media_entry)
      error = first(".ui-alert").text
      expect(error).to eq "Bitte melden Sie sich an."
    end
  
    scenario "Accessing non-accessible media entry with being logged in should inform of missing access rights" do
      @media_entry.user = User.last
      @media_entry.save
      @current_user = sign_in_as 'adam'
      visit media_entry_path(@media_entry)
      error = first(".ui-alert").text
      expect(error).to eq "Sie haben nicht die notwendige Zugriffsberechtigung."
      visit relations_media_entry_path(@media_entry)
      error = first(".ui-alert").text
      expect(error).to eq "Sie haben nicht die notwendige Zugriffsberechtigung."
    end

    scenario "Accessing accessible media entry should be successful" do
      @media_entry.view = true
      @media_entry.save
      visit media_entry_path(@media_entry)
      expect(current_path).to eq media_entry_path(@media_entry)
      visit relations_media_entry_path(@media_entry)
      expect(current_path).to eq relations_media_entry_path(@media_entry)
    end
  end
  context "media set" do
    before(:each) do
      @media_set = FactoryGirl
        .create :media_set_with_title
    end

    scenario "Accessing non exisitng media set should give 404 error" do
      visit '/sets/ddf90877-4dd9-48e9-8cf1-b146ed7ebesf'
      error = first(".title-xxl").text
      expect(error).to eq "HTTP Fehler 404 - Nicht gefunden"
      visit '/sets/ddf90877-4dd9-48e9-8cf1-b146ed7ebesf/relations'
      error = first(".title-xxl").text
      expect(error).to eq "HTTP Fehler 404 - Nicht gefunden"
    end

    scenario "Accessing non-accessible media set without being logged in should prompt for login" do
      visit media_set_path(@media_set)
      error = first(".ui-alert").text
      expect(error).to eq "Bitte melden Sie sich an."
      visit relations_media_set_path(@media_set)
      error = first(".ui-alert").text
      expect(error).to eq "Bitte melden Sie sich an."
    end
  
    scenario "Accessing non-accessible media set with being logged in should inform of missing access rights" do
      @media_set.user = User.last
      @media_set.save
      @current_user = sign_in_as 'adam'
      visit media_set_path(@media_set)
      error = first(".ui-alert").text
      expect(error).to eq "Sie haben nicht die notwendige Zugriffsberechtigung."
      visit relations_media_set_path(@media_set)
      error = first(".ui-alert").text
      expect(error).to eq "Sie haben nicht die notwendige Zugriffsberechtigung."
    end

    scenario "Accessing accessible media set should be successful" do
      @media_set.view = true
      @media_set.save
      visit media_set_path(@media_set)
      expect(current_path).to eq media_set_path(@media_set)
      visit relations_media_set_path(@media_set)
      expect(current_path).to eq relations_media_set_path(@media_set)
    end
  end
  scenario "After signing in after being prompted to do so, user should be redirected to the resource they were trying to access" do
      @user = User.first
      @media_entry = FactoryGirl
        .create :media_entry_with_image_media_file, user: @user 
      visit media_entry_path(@media_entry)  
      @current_user = sign_in_as @user.login 
      expect(current_path).to eq media_entry_path(@media_entry)
  end
end
