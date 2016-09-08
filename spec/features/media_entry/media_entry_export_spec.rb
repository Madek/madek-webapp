require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/basic_data_helper_spec'
require_relative '../shared/meta_data_helper_spec'
include BasicDataHelper
include MetaDataHelper

feature 'Resource: MediaEntry' do
  describe 'Action: export' do

    pending 'Add tests for other data types than images' do
      fail 'not implemented'
    end

    it 'Shown when logged in', browser: :firefox_nojs do
      scenario_show true
    end

    it 'Shown when not logged in', browser: :firefox_nojs do
      scenario_show false
    end

    it 'Close by cross', browser: :firefox_nojs do
      find_button = lambda do
        find('.icon-close')
      end
      scenario_close(find_button)
    end

    it 'Close by button', browser: :firefox_nojs do
      find_button = lambda do
        find('.primary-button', text: I18n.t(:media_entry_export_close))
      end
      scenario_close(find_button)
    end

    it 'Original image not accessible and no previews', browser: :firefox_nojs do
      check_combinations(false, false)
    end

    it 'Original image accessible but no previews', browser: :firefox_nojs do
      check_combinations(false, true)
    end

    it 'Original image not accessible but has previews', browser: :firefox_nojs do
      check_combinations(true, false)
    end

    it 'Download original image not logged in', browser: :firefox_nojs do
      prepare_user
      prepare_image
      open_export
      expect(page).to have_content(I18n.t(:media_entry_export_has_no_original))
      expect(page).to have_content(I18n.t(:media_entry_export_subtitle_images))
    end

    it 'Download original image logged in', browser: :firefox_nojs do
      prepare_user
      prepare_image

      initial_downloads = get_my_downloads
      wanted_file = @media_entry.media_file.original_store_location

      login
      open_export
      find('.primary-button', text: I18n.t(:media_entry_export_download)).click

      downloaded_file = get_new_download_file(initial_downloads)

      # content should be the same:
      expect(Digest::SHA256.hexdigest(File.read(downloaded_file)))
        .to eq(Digest::SHA256.hexdigest(File.read(wanted_file)))
    end

    it 'Download preview image not logged in', browser: :firefox_nojs do
      prepare_user
      prepare_image

      initial_downloads = get_my_downloads
      wanted_file = @media_entry.media_file.previews.where(thumbnail: :maximum)
                      .first.file_path

      open_export
      find('.modal').all('.icon-dload')[0].click

      downloaded_file = get_new_download_file(initial_downloads)

      # content should be the same:
      expect(Digest::SHA256.hexdigest(File.read(downloaded_file)))
        .to eq(Digest::SHA256.hexdigest(File.read(wanted_file)))
    end
  end

  private

  def expect_content(bool, content)
    if bool
      expect(page).to have_content(content)
    else
      expect(page).to have_no_content(content)
    end
  end

  def check_combinations(has_previews, original_accessible)
    prepare_user
    if has_previews
      prepare_image
    else
      prepare_image_without_previews
    end
    if original_accessible
      login
    end
    open_export

    neither_shown = (not has_previews and not original_accessible)
    expect_content(neither_shown, I18n.t(:media_entry_export_no_content))

    check_original_title_available(neither_shown == false)

    expect_content(original_accessible, I18n.t(:media_entry_export_original_hint))
    expect_content(
      (not original_accessible and not neither_shown),
      I18n.t(:media_entry_export_has_no_original))

    expect_content(has_previews, I18n.t(:media_entry_export_subtitle_images))
  end

  def check_original_title_available(bool)
    if bool
      expect(page).to have_selector(
        'h2',
        text: I18n.t(:media_entry_export_original))
    else
      expect(page).not_to have_selector(
        'h2',
        text: I18n.t(:media_entry_export_original))
    end
  end

  def scenario_show(do_login)
    prepare_user
    prepare_image
    if do_login
      login
    end
    open_export
  end

  def scenario_close(find_button)
    prepare_user
    prepare_image
    login
    open_export
    find_button.call.click
    expect(current_path).to eq(media_entry_path(@media_entry))
  end

  def open_export
    visit media_entry_path(@media_entry)
    find('.icon-dload').click
    expect(current_path).to eq(export_media_entry_path(@media_entry))
  end

  def prepare_image_without_previews
    prepare_image
    media_file = @media_entry.media_file
    media_file.previews = []
    media_file.save
  end

  def prepare_image
    @media_entry = FactoryGirl.create(
      :media_entry_with_image_media_file,
      get_metadata_and_previews: true,
      responsible_user: @user,
      creator: @user)
  end

  def get_my_downloads
    Dir.entries(BROWSER_DONWLOAD_DIR)
  end

  def get_new_download_file(initial_contents)
    # wait until there is 1 more non-partial download in users dir:
    wait_until do
      files = get_my_downloads.reject { |f| /.part$/.match f }
      next unless file = (files - initial_contents)[0]
      downloaded_file = BROWSER_DONWLOAD_DIR.join(file)
      downloaded_file if File.size(downloaded_file) > 0
    end
  end

end
