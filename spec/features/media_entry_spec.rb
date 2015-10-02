require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'MediaEntry' do
  background do
    @user = FactoryGirl.create(:user, password: 'password')
    sign_in_as @user.login
  end

  context '#create' do
    scenario 'upload and publish' do
      # go to dashboard and import button
      visit my_dashboard_path
      within('.ui-body-title-actions') do
        find('.button-primary').click
      end
      expect(current_path).to eq '/entries/new'

      # select file and submit
      within('.app-body') do
        image_path = Madek::Constants::DATALAYER_ROOT_DIR \
          .join('spec', 'data', 'images', 'grumpy_cat.jpg')
        attach_file('media_entry_media_file', File.absolute_path(image_path))
        submit_form
      end

      # unpublished entry was created
      within('#app') do
        alert = find('.ui-alert.warning')
        expect(alert).to have_content 'Entry is not published yet!'
      end

      # TODO: (when validation) add some needed meta data

      # publish it
      click_on 'Publish!'

      # it was published
      alert = find('#app-alerts .success')
      expect(alert).to have_content 'Entry was published!'

    end

    scenario 'meta_data extraction', browser: :firefox do
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
      FactoryGirl.create(:license,
                         url: 'http://creativecommons.org/licenses/by-nd/2.5/ch/')
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: 'upload:licenses',
                       key_map: 'XMP-xmpRights:WebStatement')
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: 'media_object:creator',
                       key_map: 'XMP-dc:Creator')

      # go to dashboard and import button
      visit my_dashboard_path
      within('.ui-body-title-actions') do
        find('.button-primary').click
      end
      expect(current_path).to eq '/entries/new'

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
        expect(alert).to have_content 'Entry is not published yet!'
      end

      media_entry = @user.unpublished_media_entries.first

      # media file #############################################################
      media_file = media_entry.media_file
      expect(media_file).to be
      extractor = MetadataExtractor.new(media_file.original_store_location)
      expect(media_file.meta_data).to eq extractor.to_hash
      expect(media_file.width).to be == extractor.to_hash[:image_width]
      expect(media_file.height).to be == extractor.to_hash[:image_height]

      # file and previews ######################################################
      original_dir = Madek::Constants::FILE_STORAGE_DIR.join(media_file.guid.first)
      expect(File.exist? original_dir.join(media_file.guid)).to be true

      thumbnails_dir = Madek::Constants::THUMBNAIL_STORAGE_DIR \
        .join(media_file.guid.first)
      THUMBNAILS.keys.each do |thumb_size|
        next if thumb_size == :maximum
        expect(File.exist? \
                 thumbnails_dir.join("#{media_file.guid}_#{thumb_size}.jpg")) \
        .to be true
      end
      expect(media_file.previews.size).to be == THUMBNAILS.size

      # meta data for media entry ##############################################
      ['madek_core:title', 'upload:licenses', 'media_object:creator']
        .each do |mk_id|
        meta_datum = media_entry.meta_data.find_by_meta_key_id(mk_id)
        expect(meta_datum).to be
      end
    end
  end

  scenario '#delete', browser: :firefox do
    visit media_entry_path \
      create :media_entry_with_image_media_file,
             creator: @user, responsible_user: @user

    # visit media_entry_path(media_entry)

    # main actions has a delete button with a confirmation:
    within '.ui-body-title-actions' do
      confirmation = find('.icon-trash').click
      expect(confirmation).to eq 'Are you sure you want to delete this?'
      accept_confirm
    end

    # redirects to user dashboard:
    expect(current_path).to eq my_dashboard_path

  end
end
