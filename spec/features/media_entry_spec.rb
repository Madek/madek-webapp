require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: MediaEntry' do
  background do
    @user = FactoryGirl.create(:user, password: 'password')
    sign_in_as @user.login
  end

  describe 'Action: create' do

    scenario 'upload and publish an image with javascript disabled' do
      # go to dashboard and import button
      visit my_dashboard_path
      within('.ui-body-title-actions') do
        find('a', text: I18n.t('dashboard_create_media_entry_btn')).click
      end
      expect(current_path).to eq new_media_entry_path

      # select file and submit
      within('.app-body') do
        image_path = Madek::Constants::DATALAYER_ROOT_DIR \
          .join('spec', 'data', 'images', 'grumpy_cat.jpg')
        attach_file('media_entry_media_file', File.absolute_path(image_path))
        submit_form
      end

      expect(page.status_code).to eq 200

      # unpublished entry was created
      within('#app') do
        alert = find('.ui-alert.warning')
        expect(alert)
          .to have_content I18n.t(:media_entry_not_published_warning_msg)
      end

      # NOTE: will break here when there is required MetaData,
      # must add them here

      # publish it
      click_on I18n.t(:btn_publish_text)

      # it was published
      alert = find('#app-alerts .success')
      expect(alert).to have_content 'Entry was published!'

    end

    scenario 'File metadata is extracted and mapped via IoMappings to MetaData' do

      unless MetaKey.where(id: 'madek_core:title').exists?
        FactoryGirl.create(:meta_key_text, id: 'madek_core:title')
      end
      IoInterface.find_or_create_by(id: 'default')
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: 'madek_core:title',
                       key_map: 'XMP-dc:Title')
      FactoryGirl.create(:meta_key,
                         id: 'upload:licenses',
                         meta_datum_object_type: 'MetaDatum::Licenses')
      FactoryGirl.create(:license)
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: 'upload:licenses',
                       key_map: 'XMP-xmpRights:WebStatement')
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: 'media_object:creator',
                       key_map: 'XMP-dc:Creator')

      # go to dashboard and import button
      visit my_dashboard_path
      within('.ui-body-title-actions') do
        find('a', text: I18n.t('dashboard_create_media_entry_btn')).click
      end
      expect(current_path).to eq new_media_entry_path

      # select file and submit
      within('.app-body') do
        image_path = Madek::Constants::DATALAYER_ROOT_DIR \
          .join('spec', 'data', 'images', 'grumpy_cat_new.jpg')
        attach_file('media_entry_media_file', File.absolute_path(image_path))
        submit_form
      end

      # unpublished entry was created
      within('#app') do
        alert = find('.ui-alert.warning')
        expect(alert)
          .to have_content I18n.t(:media_entry_not_published_warning_msg)
      end

      media_entry = @user.unpublished_media_entries.first

      # media file #############################################################
      media_file = media_entry.media_file
      expect(media_file).to be
      extractor = MetadataExtractor
        .new(media_file.original_store_location).to_hash.transform_values do |val|
          begin; val.to_json; rescue; next '(Binary or unknown data)'; end
          val
        end

      expect(media_file.meta_data).to eq extractor
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
      ['madek_core:title', 'upload:licenses', 'media_object:creator']
        .each do |mk_id|
        meta_datum = media_entry.meta_data.find_by_meta_key_id(mk_id)
        expect(meta_datum).to be
      end
    end
  end

  describe 'Action: delete' do

    scenario 'via delete button on detail view ' \
             '(with confirmation)', browser: :firefox do

      visit media_entry_path \
        create :media_entry_with_image_media_file,
               creator: @user, responsible_user: @user

      # main actions has a delete button with a confirmation:
      within '.ui-body-title-actions' do
        confirmation = find('.icon-trash').click
        expect(confirmation).to eq I18n.t(:btn_delete_confirm_msq)
        accept_confirm
      end

      # redirects to user dashboard:
      expect(current_path).to eq my_dashboard_path
    end

  end
end
