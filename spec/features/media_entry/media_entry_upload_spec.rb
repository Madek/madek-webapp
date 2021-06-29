require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: MediaEntry' do

  background do
    @user = FactoryGirl.create(:user, password: 'password')
    sign_in_as @user.login
  end

  describe 'Action: create (upload/import)' do

    scenario 'upload and publish an image (no Javascript)',
             browser: :firefox_nojs do
      # go to dashboard and import button
      visit my_dashboard_path
      within('.ui-body-title-actions') do
        find('a', text: I18n.t('dashboard_create_media_entry_btn')).click
      end
      expect(current_path).to eq new_media_entry_path

      select_file_and_submit('images', 'grumpy_cat_new.jpg')

      expect(page).to have_content 'Media entry wurde erstellt.'

      # FIXME: re-activate this:

      # # unpublished entry was created
      # within('#app') do
      #   alert = find('.ui-alert.warning')
      #   expect(alert)
      #     .to have_content I18n.t(:media_entry_not_published_warning_msg)
      # end
      #
      # # NOTE: will break here when there is required MetaData,
      # # must add them here
      #
      # # publish it
      # click_on I18n.t(:btn_publish_text)
      #
      # # it was published
      # alert = find('#app-alerts .success')
      # expect(alert).to have_content 'Entry was published!'

    end

    scenario 'Default License and Usage are applied on upload as configured',
             browser: false do
      settings = AppSetting.first

      visit new_media_entry_path
      select_file_and_submit('images', 'grumpy_cat_new.jpg')
      media_entry = @user.unpublished_media_entries.first

      md_license = media_entry.meta_data
        .find_by_meta_key_id(settings.media_entry_default_license_meta_key)

      md_usage = media_entry.meta_data
        .find_by_meta_key_id(settings.media_entry_default_license_usage_meta_key)

      expect(md_usage.string).to eq settings.media_entry_default_license_usage_text

      expect(md_license.keywords.first.id)
        .to eq settings.media_entry_default_license_id
    end

    scenario 'File metadata is extracted and mapped via IoMappings to MetaData',
             browser: false do

      unless MetaKey.where(id: 'madek_core:title').exists?
        FactoryGirl.create(:meta_key_text, id: 'madek_core:title')
      end
      IoInterface.find_or_create_by(id: 'default')
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: 'madek_core:title',
                       key_map: 'XMP-dc:Title')
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: 'media_object:creator',
                       key_map: 'XMP-dc:Creator')

      visit new_media_entry_path
      select_file_and_submit('images', 'grumpy_cat_new.jpg')
      media_entry = @user.unpublished_media_entries.first

      # media file #############################################################
      media_file = media_entry.media_file
      expect(media_file).to be
      extractor = MetadataExtractor
        .new(media_file.original_store_location).to_hash.transform_values do |val|
          begin; val.to_json; rescue; next '(Binary or unknown data)'; end
          val
        end

      expect(only_relevant_metadata(media_file.meta_data))
        .to eq only_relevant_metadata(extractor)
      expect(media_file.width).to be == extractor[:image_width]
      expect(media_file.height).to be == extractor[:image_height]

      # file and previews ######################################################
      original_dir = Madek::Constants::FILE_STORAGE_DIR.join(media_file.guid.first)
      expect(File.exist? original_dir.join(media_file.guid)).to be true

      thumbnails_dir = Madek::Constants::THUMBNAIL_STORAGE_DIR \
        .join(media_file.guid.first)
      Madek::Constants::THUMBNAILS.keys.each do |thumb_size|
        next if thumb_size == :maximum
        expect(File.exist? \
                 thumbnails_dir.join("#{media_file.guid}_#{thumb_size}.jpg")) \
        .to be true
      end
      expect(media_file.previews.size).to be == Madek::Constants::THUMBNAILS.size

      # meta data for media entry ##############################################
      ['madek_core:title', 'media_object:creator']
        .each do |mk_id|
        meta_datum = media_entry.meta_data.find_by_meta_key_id(mk_id)
        expect(meta_datum).to be
      end
    end

  end
end

private

def only_relevant_metadata(hash)
  ignored = ['System:FileAccessDate']
  hash.except(*ignored)
end
