require 'spec_helper'
require Rails.root.join 'spec',
                        'controllers',
                        'shared',
                        'media_resources',
                        'authorization.rb'

describe MediaEntriesController do

  before :example do
    @user = FactoryGirl.create :user
  end

  it 'create' do
    unless MetaKey.where(id: 'madek_core:title').exists?
      FactoryGirl.create(:meta_key_text, id: 'madek_core:title')
    end
    image_path = Rails.root.join('spec', 'data', 'images', 'grumpy_cat.jpg')
    IoInterface.find_or_create_by(id: 'default')
    IoMapping.create(io_interface_id: 'default',
                     meta_key_id: 'madek_core:title',
                     key_map: 'XMP-dc:Title')

    post_params = \
      { media_entry: \
        { responsible_user_id: @user.id,
          creator_id: @user.id,
          media_file: {
            file: fixture_file_upload(image_path, 'image/jpg'),
            uploader_id: @user.id
          }
        }
      }

    post :create, post_params, user_id: @user.id
    expect(response.redirect?).to be true
    expect(@user.media_entries.count).to be 1
    media_entry = @user.media_entries.first

    # media file #################################################################
    media_file = media_entry.media_file
    expect(media_file).to be
    extractor = MetadataExtractor.new(media_file.store_location)
    expect(media_file.meta_data).to be == extractor.to_hash
    expect(media_file.width).to be == extractor.to_hash[:image_width]
    expect(media_file.height).to be == extractor.to_hash[:image_height]

    # file and previews ##########################################################
    folder_path = \
      "#{Rails.root}/db/media_files/test/attachments/#{media_file.guid.first}/"
    expect(File.exist? "#{folder_path}#{media_file.guid}").to be true

    THUMBNAILS.keys.each do |thumb_size|
      next if thumb_size == :maximum
      expect(File.exist? "#{folder_path}#{media_file.guid}_#{thumb_size}.jpg")
        .to be true
    end
    expect(media_file.previews.size).to be == THUMBNAILS.size

    # meta data for media entry ##################################################
    meta_datum = media_entry.meta_data.find_by_meta_key_id('madek_core:title')
    expect(meta_datum).to be
  end

  it_performs 'authorization'
end
