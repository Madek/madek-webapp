require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'Resource: MediaEntry' do
  given(:user) { create(:user, password: 'password') }

  background do
    sign_in_as user.login
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
    end

    scenario 'upload and publish an video (no Javascript)',
             browser: :firefox_nojs do
      # go to dashboard and import button
      visit my_dashboard_path
      within('.ui-body-title-actions') do
        find('a', text: I18n.t('dashboard_create_media_entry_btn')).click
      end
      expect(current_path).to eq new_media_entry_path

      select_file_and_submit('images', 'grumpy_cat_new.jpg')

      expect(page).to have_content 'Media entry wurde erstellt.'

    end

    scenario 'upload a single jpg image' do
      # go to dashboard and import button
      visit my_dashboard_path
      within('.ui-body-title-actions') do
        find('a', text: I18n.t('dashboard_create_media_entry_btn')).click
      end
      expect(current_path).to eq new_media_entry_path
      attach_file('media_entry[media_file][]', Rails.root.join('spec', 'data', 'sample.jpg'), make_visible: true)
      expect(page).to have_css('img[title="sample.jpg"]')

      expect(page).to have_no_css('a.disabled', text: 'Medieneinträge vervollständigen')
    end

    scenario 'upload a single tiff image' do
      # go to dashboard and import button
      visit my_dashboard_path
      within('.ui-body-title-actions') do
        find('a', text: I18n.t('dashboard_create_media_entry_btn')).click
      end
      expect(current_path).to eq new_media_entry_path
      attach_file('media_entry[media_file][]', Rails.root.join('spec', 'data', 'sample.tif'), make_visible: true)
      expect(page).to have_css('img[title="sample.tif"]')

      expect(page).to have_no_css('a.disabled', text: 'Medieneinträge vervollständigen')
    end

    scenario 'upload a too large image' do
      # go to dashboard and import button
      visit my_dashboard_path
      within('.ui-body-title-actions') do
        find('a', text: I18n.t('dashboard_create_media_entry_btn')).click
      end
      expect(current_path).to eq new_media_entry_path

      attach_file('media_entry[media_file][]', Rails.root.join('spec', 'data', '17k-test.jpg'), make_visible: true)
      expect(page).to_not have_css('img[title="17k-test.jpg"]')
      expect(page).to have_content('17k-test.jpg überschreitet maximale Grösse von 16000 Pixel')
      expect(page).to have_no_css('a.disabled', text: 'Medieneinträge vervollständigen')
    end

    scenario 'upload a single pdf' do
      # go to dashboard and import button
      visit my_dashboard_path
      within('.ui-body-title-actions') do
        find('a', text: I18n.t('dashboard_create_media_entry_btn')).click
      end
      expect(current_path).to eq new_media_entry_path

      attach_file('media_entry[media_file][]', Rails.root.join('spec', 'data', 'sample.pdf'), make_visible: true)
      expect(page).to have_css('img[title="sample.pdf"]')

      expect(page).to have_no_css('a.disabled', text: 'Medieneinträge vervollständigen')
    end

    scenario 'upload multiple files' do
      # go to dashboard and import button
      visit my_dashboard_path
      within('.ui-body-title-actions') do
        find('a', text: I18n.t('dashboard_create_media_entry_btn')).click
      end
      expect(current_path).to eq new_media_entry_path

      attach_file('media_entry[media_file][]', 
        [
          Rails.root.join('spec', 'data', 'sample.jpg'),
          Rails.root.join('spec', 'data', 'sample.pdf'),
          Rails.root.join('spec', 'data', '17k-test.jpg')
        ], make_visible: true)
    
      expect(page).to have_css('img[title="sample.jpg"]')
      expect(page).to have_css('img[title="sample.pdf"]')

      expect(page).to_not have_css('img[title="17k-test.jpg"]')
      expect(page).to have_content('17k-test.jpg überschreitet maximale Grösse von 16000 Pixel')
      expect(page).to have_no_css('a.disabled', text: 'Medieneinträge vervollständigen')
    end

    scenario 'upload same two files a second time yields four previews' do
      visit my_dashboard_path
      within('.ui-body-title-actions') do
        find('a', text: I18n.t('dashboard_create_media_entry_btn')).click
      end
      expect(current_path).to eq new_media_entry_path

      files = [
        Rails.root.join('spec', 'data', 'sample.jpg'),
        Rails.root.join('spec', 'data', 'sample.pdf')
      ]

      attach_file('media_entry[media_file][]', files, make_visible: true)
      attach_file('media_entry[media_file][]', files, make_visible: true)

      expect(page).to have_content('4 Upload(s)')
      within('[data-test-id="resources-box"]') do
        expect(page).to have_css('.ui-resource', count: 4)
        expect(page).to have_css('img[title="sample.jpg"]', count: 2)
        expect(page).to have_css('img[title="sample.pdf"]', count: 2)
      end
      expect(page).to have_no_css('a.disabled', text: 'Medieneinträge vervollständigen')
    end

    scenario 'large file shows progress, default icon, and correct upload count' do
      visit my_dashboard_path
      within('.ui-body-title-actions') do
        find('a', text: I18n.t('dashboard_create_media_entry_btn')).click
      end
      expect(current_path).to eq new_media_entry_path

      attach_file(
        'media_entry[media_file][]',
        Rails.root.join('spec', 'data', 'sample.tif'),
        make_visible: true
      )

      within('[data-test-id="resources-box"]') do
        expect(page).to have_content('1 Upload(s)')
        expect(page).to have_css('.ui-resource', count: 1)
        expect(page).to have_css('.ui_media-type-icon')
        expect(page).to have_content(/Hochladen…|Verarbeiten…/)
      end

      expect(page).to have_css('img[title="sample.tif"]')
      expect(page).to have_content('1 Upload(s)')
      expect(page).to have_no_css('a.disabled', text: 'Medieneinträge vervollständigen')
    end

    scenario 'Default License and Usage are applied on upload as configured',
             browser: false do
      settings = AppSetting.first

      visit new_media_entry_path
      select_file_and_submit('images', 'grumpy_cat_new.jpg')
      media_entry = user.unpublished_media_entries.first

      md_license = media_entry.meta_data
        .find_by_meta_key_id(settings.media_entry_default_license_meta_key)

      md_usage = media_entry.meta_data
        .find_by_meta_key_id(settings.media_entry_default_license_usage_meta_key)

      expect(md_usage.string).to eq settings.media_entry_default_license_usage_text

      expect(md_license.keywords.first.id)
        .to eq settings.media_entry_default_license_id
    end

    scenario 'All preview sizes are generated for a 2000x1500 image',
             browser: false do
      visit new_media_entry_path
      select_file_and_submit('images', 'sleepy_cat_2000.jpg')
      media_entry = user.unpublished_media_entries.first
      media_file = media_entry.media_file

      expect(media_file.width).to be == 2000
      expect(media_file.height).to be == 1500

      thumbnails_dir = Madek::Constants::THUMBNAIL_STORAGE_DIR
                       .join(media_file.guid.first)

      Madek::Constants::THUMBNAILS.keys.each do |thumb_size|
        expect(File.exist?(thumbnails_dir.join("#{media_file.guid}_#{thumb_size}.jpg")))
          .to be(true), "expected preview size #{thumb_size} to exist"
      end

      expect(media_file.previews.size).to be == Madek::Constants::THUMBNAILS.size
    end

    scenario 'Only preview sizes below `x_grand` are generated for a 1600x1200 image',
             browser: false do
      visit new_media_entry_path
      select_file_and_submit('images', 'sleepy_cat_1600.jpg')
      media_entry = user.unpublished_media_entries.first
      media_file = media_entry.media_file

      expect(media_file.width).to be == 1600
      expect(media_file.height).to be == 1200

      thumbnails_dir = Madek::Constants::THUMBNAIL_STORAGE_DIR
                       .join(media_file.guid.first)

      Madek::Constants::THUMBNAILS.keys.each do |thumb_size|
        if thumb_size == :x_grand
          expect(File.exist?(thumbnails_dir.join("#{media_file.guid}_#{thumb_size}.jpg")))
            .to be(false), "expected preview size #{thumb_size} not to exist"
        else
          expect(File.exist?(thumbnails_dir.join("#{media_file.guid}_#{thumb_size}.jpg")))
            .to be(true), "expected preview size #{thumb_size} to exist"
        end
      end

      expect(media_file.previews.size).to be == Madek::Constants::THUMBNAILS.size - 1
    end

    scenario 'Only preview sizes below `grand` are generated for a 1280x960 image',
             browser: false do
      visit new_media_entry_path
      select_file_and_submit('images', 'sleepy_cat_1280.jpg')
      media_entry = user.unpublished_media_entries.first
      media_file = media_entry.media_file

      expect(media_file.width).to be == 1280
      expect(media_file.height).to be == 960

      thumbnails_dir = Madek::Constants::THUMBNAIL_STORAGE_DIR
                       .join(media_file.guid.first)

      Madek::Constants::THUMBNAILS.keys.each do |thumb_size|
        if thumb_size == :grand || thumb_size == :x_grand
          expect(File.exist?(thumbnails_dir.join("#{media_file.guid}_#{thumb_size}.jpg")))
            .to be(false), "expected preview size #{thumb_size} not to exist"
        else
          expect(File.exist?(thumbnails_dir.join("#{media_file.guid}_#{thumb_size}.jpg")))
            .to be(true), "expected preview size #{thumb_size} to exist"
        end
      end

      expect(media_file.previews.size).to be == Madek::Constants::THUMBNAILS.size - 2
    end

    scenario 'Only `medium` and `maximum` are generated for a 620x464 image',
             browser: false do
      visit new_media_entry_path
      select_file_and_submit('images', 'grumpy_cat_620.jpg')
      media_entry = user.unpublished_media_entries.first
      media_file = media_entry.media_file

      expect(media_file.width).to be == 620
      expect(media_file.height).to be == 464

      thumbnails_dir = Madek::Constants::THUMBNAIL_STORAGE_DIR
                       .join(media_file.guid.first)

      Madek::Constants::THUMBNAILS.keys.each do |thumb_size|
        if thumb_size != :maximum && thumb_size != :medium
          expect(File.exist?(thumbnails_dir.join("#{media_file.guid}_#{thumb_size}.jpg")))
            .to be(false), "expected preview size #{thumb_size} not to exist"
        else
          expect(File.exist?(thumbnails_dir.join("#{media_file.guid}_#{thumb_size}.jpg")))
            .to be(true), "expected preview size #{thumb_size} to exist"
        end
      end

      expect(media_file.previews.size).to be == 2
    end

    scenario 'File metadata is extracted and mapped via IoMappings to MetaData',
             browser: false do

      unless MetaKey.where(id: 'madek_core:title').exists?
        FactoryBot.create(:meta_key_text, id: 'madek_core:title')
      end
      IoInterface.find_or_create_by(id: 'default')
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: 'madek_core:title',
                       key_map: 'Filename')
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: 'media_object:creator',
                       key_map: 'XMP-dc:Creator')
      IoMapping.where(io_interface_id: 'default', key_map: 'XMP-dc:Title').destroy_all

      visit new_media_entry_path
      select_file_and_submit('images', 'grumpy_cat_new.jpg')
      media_entry = user.unpublished_media_entries.first

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
      expect(media_file.width).to be == 480
      expect(media_file.height).to be == 360

      # file and previews ######################################################
      original_dir = Madek::Constants::FILE_STORAGE_DIR.join(media_file.guid.first)
      expect(File.exist? original_dir.join(media_file.guid)).to be true

      thumbnails_dir = Madek::Constants::THUMBNAIL_STORAGE_DIR \
        .join(media_file.guid.first)
      expected_presence_map = { maximum: true, x_grand: false, grand: false, x_large: false, large: false, medium: true }
      Madek::Constants::THUMBNAILS.keys.each do |thumb_size|
        expected_presence = expected_presence_map.fetch(thumb_size)
        puts "#{thumb_size} #{expected_presence}"
        expect(File.exist? \
                 thumbnails_dir.join("#{media_file.guid}_#{thumb_size}.jpg")) \
        .to be expected_presence
      end
      expect(media_file.previews.size).to be == 2

      # meta data for media entry ##############################################

      expect(media_entry.meta_data.find_by_meta_key_id('madek_core:title')).to be
      expect(media_entry.meta_data.find_by_meta_key_id('madek_core:title').string).to eq('grumpy_cat_new.jpg')
      expect(media_entry.meta_data.find_by_meta_key_id('media_object:creator')).to be
    end

    scenario 'File metadata referencing a Person by UUID (custom madek XMP namespace) ' \
             'is extracted and mapped via IoMappings to People MetaData',
             browser: false do

      person = create(:person)
      meta_key = create(:meta_key_people)
      IoInterface.find_or_create_by(id: 'default')
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: meta_key.id,
                       key_map: 'XMP-madek:Author')

      tagged_image = Rails.root.join('tmp', "tagged_#{SecureRandom.hex(8)}.jpg")
      FileUtils.cp(
        Madek::Constants::DATALAYER_ROOT_DIR.join('spec', 'data', 'images', 'grumpy_cat_new.jpg'),
        tagged_image)
      config_path =
        Rails.root.join('config', 'definitions', 'metadata', 'ExifTool_config.pl')
      system('exiftool', '-config', config_path.to_s,
             "-XMP-madek:Author=#{person.id}", '-overwrite_original',
             tagged_image.to_s, exception: true)

      begin
        visit new_media_entry_path
        within('.app-body') do
          attach_file('media_entry_media_file', tagged_image.to_s, make_visible: true)
          submit_form
        end

        media_entry = user.unpublished_media_entries.first
        people_meta_datum = media_entry.meta_data.find_by_meta_key_id(meta_key.id)
        expect(people_meta_datum).to be
        expect(people_meta_datum.people).to include(person)
      ensure
        FileUtils.rm_f(tagged_image)
      end
    end

    scenario 'File metadata referencing multiple People by comma-separated UUIDs ' \
             'is extracted and mapped via IoMappings to People MetaData',
             browser: false do

      person_a = create(:person)
      person_b = create(:person)
      meta_key = create(:meta_key_people)
      IoInterface.find_or_create_by(id: 'default')
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: meta_key.id,
                       key_map: 'XMP-madek:Author')

      tagged_image = Rails.root.join('tmp', "tagged_#{SecureRandom.hex(8)}.jpg")
      FileUtils.cp(
        Madek::Constants::DATALAYER_ROOT_DIR.join('spec', 'data', 'images', 'grumpy_cat_new.jpg'),
        tagged_image)
      config_path =
        Rails.root.join('config', 'definitions', 'metadata', 'ExifTool_config.pl')
      system('exiftool', '-config', config_path.to_s,
             "-XMP-madek:Author=#{person_a.id},#{person_b.id}", '-overwrite_original',
             tagged_image.to_s, exception: true)

      begin
        visit new_media_entry_path
        within('.app-body') do
          attach_file('media_entry_media_file', tagged_image.to_s, make_visible: true)
          submit_form
        end

        media_entry = user.unpublished_media_entries.first
        people_meta_datum = media_entry.meta_data.find_by_meta_key_id(meta_key.id)
        expect(people_meta_datum).to be
        expect(people_meta_datum.people).to include(person_a, person_b)
      ensure
        FileUtils.rm_f(tagged_image)
      end
    end

    scenario 'File metadata referencing a Person by an internal <URL> ' \
             'is extracted and mapped via IoMappings to People MetaData',
             browser: false do

      person = create(:person)
      meta_key = create(:meta_key_people)
      IoInterface.find_or_create_by(id: 'default')
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: meta_key.id,
                       key_map: 'XMP-madek:Author')

      tagged_image = Rails.root.join('tmp', "tagged_#{SecureRandom.hex(8)}.jpg")
      FileUtils.cp(
        Madek::Constants::DATALAYER_ROOT_DIR.join('spec', 'data', 'images', 'grumpy_cat_new.jpg'),
        tagged_image)
      config_path =
        Rails.root.join('config', 'definitions', 'metadata', 'ExifTool_config.pl')
      person_url = "<http://www.example.com/people/#{person.id}>"
      system('exiftool', '-config', config_path.to_s,
             "-XMP-madek:Author=#{person_url}", '-overwrite_original',
             tagged_image.to_s, exception: true)

      begin
        visit new_media_entry_path
        within('.app-body') do
          attach_file('media_entry_media_file', tagged_image.to_s, make_visible: true)
          submit_form
        end

        media_entry = user.unpublished_media_entries.first
        people_meta_datum = media_entry.meta_data.find_by_meta_key_id(meta_key.id)
        expect(people_meta_datum).to be
        expect(people_meta_datum.people).to include(person)
      ensure
        FileUtils.rm_f(tagged_image)
      end
    end

    scenario 'File metadata referencing a Person by a bare-path <URL> ' \
             'is extracted and mapped via IoMappings to People MetaData',
             browser: false do

      person = create(:person)
      meta_key = create(:meta_key_people)
      IoInterface.find_or_create_by(id: 'default')
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: meta_key.id,
                       key_map: 'XMP-madek:Author')

      tagged_image = Rails.root.join('tmp', "tagged_#{SecureRandom.hex(8)}.jpg")
      FileUtils.cp(
        Madek::Constants::DATALAYER_ROOT_DIR.join('spec', 'data', 'images', 'grumpy_cat_new.jpg'),
        tagged_image)
      config_path =
        Rails.root.join('config', 'definitions', 'metadata', 'ExifTool_config.pl')
      person_url = "<people/#{person.id}>"
      system('exiftool', '-config', config_path.to_s,
             "-XMP-madek:Author=#{person_url}", '-overwrite_original',
             tagged_image.to_s, exception: true)

      begin
        visit new_media_entry_path
        within('.app-body') do
          attach_file('media_entry_media_file', tagged_image.to_s, make_visible: true)
          submit_form
        end

        media_entry = user.unpublished_media_entries.first
        people_meta_datum = media_entry.meta_data.find_by_meta_key_id(meta_key.id)
        expect(people_meta_datum).to be
        expect(people_meta_datum.people).to include(person)
      ensure
        FileUtils.rm_f(tagged_image)
      end
    end

    scenario 'File metadata referencing a Keyword by UUID ' \
             'is extracted and mapped via IoMappings to Keywords MetaData',
             browser: false do

      meta_key = create(:meta_key_keywords)
      keyword = create(:keyword, meta_key: meta_key)
      IoInterface.find_or_create_by(id: 'default')
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: meta_key.id,
                       key_map: 'XMP-madek:Remark')

      tagged_image = Rails.root.join('tmp', "tagged_#{SecureRandom.hex(8)}.jpg")
      FileUtils.cp(
        Madek::Constants::DATALAYER_ROOT_DIR.join('spec', 'data', 'images', 'grumpy_cat_new.jpg'),
        tagged_image)
      config_path =
        Rails.root.join('config', 'definitions', 'metadata', 'ExifTool_config.pl')
      system('exiftool', '-config', config_path.to_s,
             "-XMP-madek:Remark=#{keyword.id}", '-overwrite_original',
             tagged_image.to_s, exception: true)

      begin
        visit new_media_entry_path
        within('.app-body') do
          attach_file('media_entry_media_file', tagged_image.to_s, make_visible: true)
          submit_form
        end

        media_entry = user.unpublished_media_entries.first
        keywords_meta_datum = media_entry.meta_data.find_by_meta_key_id(meta_key.id)
        expect(keywords_meta_datum).to be
        expect(keywords_meta_datum.keywords).to include(keyword)
      ensure
        FileUtils.rm_f(tagged_image)
      end
    end

    scenario 'File metadata referencing multiple Keywords by comma-separated UUIDs ' \
             'is extracted and mapped via IoMappings to Keywords MetaData',
             browser: false do

      meta_key = create(:meta_key_keywords)
      keyword_a = create(:keyword, meta_key: meta_key)
      keyword_b = create(:keyword, meta_key: meta_key)
      IoInterface.find_or_create_by(id: 'default')
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: meta_key.id,
                       key_map: 'XMP-madek:Remark')

      tagged_image = Rails.root.join('tmp', "tagged_#{SecureRandom.hex(8)}.jpg")
      FileUtils.cp(
        Madek::Constants::DATALAYER_ROOT_DIR.join('spec', 'data', 'images', 'grumpy_cat_new.jpg'),
        tagged_image)
      config_path =
        Rails.root.join('config', 'definitions', 'metadata', 'ExifTool_config.pl')
      system('exiftool', '-config', config_path.to_s,
             "-XMP-madek:Remark=#{keyword_a.id},#{keyword_b.id}", '-overwrite_original',
             tagged_image.to_s, exception: true)

      begin
        visit new_media_entry_path
        within('.app-body') do
          attach_file('media_entry_media_file', tagged_image.to_s, make_visible: true)
          submit_form
        end

        media_entry = user.unpublished_media_entries.first
        keywords_meta_datum = media_entry.meta_data.find_by_meta_key_id(meta_key.id)
        expect(keywords_meta_datum).to be
        expect(keywords_meta_datum.keywords).to include(keyword_a, keyword_b)
      ensure
        FileUtils.rm_f(tagged_image)
      end
    end

    scenario 'File metadata referencing a Keyword by an internal <URL> ' \
             'is extracted and mapped via IoMappings to Keywords MetaData',
             browser: false do

      meta_key = create(:meta_key_keywords)
      keyword = create(:keyword, meta_key: meta_key)
      IoInterface.find_or_create_by(id: 'default')
      IoMapping.create(io_interface_id: 'default',
                       meta_key_id: meta_key.id,
                       key_map: 'XMP-madek:Remark')

      tagged_image = Rails.root.join('tmp', "tagged_#{SecureRandom.hex(8)}.jpg")
      FileUtils.cp(
        Madek::Constants::DATALAYER_ROOT_DIR.join('spec', 'data', 'images', 'grumpy_cat_new.jpg'),
        tagged_image)
      config_path =
        Rails.root.join('config', 'definitions', 'metadata', 'ExifTool_config.pl')
      keyword_url = "<http://www.example.com/vocabulary/keyword/#{keyword.id}>"
      system('exiftool', '-config', config_path.to_s,
             "-XMP-madek:Remark=#{keyword_url}", '-overwrite_original',
             tagged_image.to_s, exception: true)

      begin
        visit new_media_entry_path
        within('.app-body') do
          attach_file('media_entry_media_file', tagged_image.to_s, make_visible: true)
          submit_form
        end

        media_entry = user.unpublished_media_entries.first
        keywords_meta_datum = media_entry.meta_data.find_by_meta_key_id(meta_key.id)
        expect(keywords_meta_datum).to be
        expect(keywords_meta_datum.keywords).to include(keyword)
      ensure
        FileUtils.rm_f(tagged_image)
      end
    end
  end

  describe 'Copying meta datum from another media entry' do
    given(:media_entry) { create(:media_entry_with_image_media_file) }

    context 'when user has no relation with media entry' do
      scenario 'the user is not allowed to make a copy' do
        visit new_media_entry_path('copy-md-from-id': media_entry.id)

        expect(page).to have_selector('#app-client-error', text: I18n.t(:error_403_title))
      end
    end

    context 'when user is a responsible for media entry' do
      given!(:media_entry) { create(:media_entry_with_image_media_file, responsible_user: user) }

      scenario 'Display header with configuration options', browser: false do
        visit new_media_entry_path('copy-md-from-id': media_entry.id)

        select_file_and_submit('images', 'grumpy_cat_new.jpg')
      end
    end
  end
end

private

def only_relevant_metadata(hash)
  ignored = ['System:FileAccessDate']
  hash.except(*ignored)
end
