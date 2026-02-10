require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

feature 'Resource: MediaEntry' do
  describe 'Action: checksum' do

    background do
      prepare_user
      @media_entry = FactoryBot.create(
        :media_entry_with_image_media_file,
        get_metadata_and_previews: true,
        responsible_user: @user,
        creator: @user)
      login
    end

    scenario 'Generate checksum for media file', browser: :firefox do
      visit export_media_entry_path(@media_entry)

      within('.ui-export-block', text: I18n.t(:media_entry_export_checksum_title)) do
        expect(page).to have_button(I18n.t(:media_entry_export_checksum_generate))
        expect(page).to have_content(I18n.t(:media_entry_export_checksum_empty))
        expect(page).to have_content('sha256')

        find('button', text: I18n.t(:media_entry_export_checksum_generate)).click

        expect(page).to have_content(/sha256: [a-f0-9]{64}/)

        expect(page).to have_content(/sha256: [a-f0-9]{64}/)
        expect(page).to have_content(I18n.t(:media_entry_export_checksum_generated_at))
        expect(page).to have_content(/\d{2}\.\d{2}\.\d{4}/)
        expect(page).to have_button(I18n.t(:media_entry_export_checksum_verify))
      end
    end

    scenario 'Verify checksum for media file', browser: :firefox do
      @media_entry.media_file.generate_checksum!
      visit export_media_entry_path(@media_entry)

      within('.ui-export-block', text: I18n.t(:media_entry_export_checksum_title)) do
        checksum_value = @media_entry.media_file.checksum
        expect(page).to have_content("sha256: #{checksum_value}")
        expect(page).to have_content(I18n.t(:media_entry_export_checksum_generated_at))
        expect(page).to have_button(I18n.t(:media_entry_export_checksum_verify))

        find('button', text: I18n.t(:media_entry_export_checksum_verify)).click

        expect(page).to have_content(I18n.t(:media_entry_export_checksum_match))

        expect(page).to have_content(I18n.t(:media_entry_export_checksum_match))
        expect(page).to have_content("sha256: #{checksum_value}")
        expect(page).to have_content(I18n.t(:media_entry_export_checksum_verified_at))
        expect(page).to have_no_content(I18n.t(:media_entry_export_checksum_generated_at))
      end
    end

    scenario 'Checksum section only visible when original file accessible', browser: :firefox do
      visit export_media_entry_path(@media_entry)
      expect(page).to have_content(I18n.t(:media_entry_export_checksum_title))

      visit my_dashboard_section_path(section: 'used_keywords')
      logout
      visit export_media_entry_path(@media_entry)
      expect(page).to have_no_content(I18n.t(:media_entry_export_checksum_title))
    end

    scenario 'Display empty state when no checksum exists', browser: :firefox do
      visit export_media_entry_path(@media_entry)

      within('.ui-export-block', text: I18n.t(:media_entry_export_checksum_title)) do
        expect(page).to have_content(I18n.t(:media_entry_export_checksum_empty))
        expect(page).to have_content('sha256')
        expect(page).to have_button(I18n.t(:media_entry_export_checksum_generate))
      end
    end

    scenario 'Display existing checksum with verified timestamp', browser: :firefox do
      @media_entry.media_file.generate_checksum!
      @media_entry.media_file.verify_checksum!
      visit export_media_entry_path(@media_entry)

      within('.ui-export-block', text: I18n.t(:media_entry_export_checksum_title)) do
        checksum_value = @media_entry.media_file.checksum
        expect(page).to have_content("sha256: #{checksum_value}")
        expect(page).to have_content(I18n.t(:media_entry_export_checksum_verified_at))
        expect(page).to have_content(/\d{2}\.\d{2}\.\d{4}/)
        expect(page).to have_no_content(I18n.t(:media_entry_export_checksum_generated_at))
        expect(page).to have_button(I18n.t(:media_entry_export_checksum_verify))
        expect(page).to have_no_button(I18n.t(:media_entry_export_checksum_generate))
      end
    end

    scenario 'Display generated checksum before verification', browser: :firefox do
      @media_entry.media_file.generate_checksum!
      visit export_media_entry_path(@media_entry)

      within('.ui-export-block', text: I18n.t(:media_entry_export_checksum_title)) do
        checksum_value = @media_entry.media_file.checksum
        expect(page).to have_content("sha256: #{checksum_value}")
        expect(page).to have_content(I18n.t(:media_entry_export_checksum_generated_at))
        expect(page).to have_no_content(I18n.t(:media_entry_export_checksum_verified_at))
        expect(page).to have_content(/\d{2}\.\d{2}\.\d{4}/)
        expect(page).to have_button(I18n.t(:media_entry_export_checksum_verify))
        expect(page).to have_no_button(I18n.t(:media_entry_export_checksum_generate))
      end
    end

  end
end
