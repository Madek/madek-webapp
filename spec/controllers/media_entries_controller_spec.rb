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

  it_performs 'authorization'

  it 'create (by uploading media_file)' do
    unless MetaKey.where(id: 'madek_core:title').exists?
      FactoryGirl.create(:meta_key_text, id: 'madek_core:title')
    end
    image_path = Rails.root.join('spec', 'data', 'images', 'grumpy_cat.jpg')
    IoInterface.find_or_create_by(id: 'default')
    IoMapping.create(io_interface_id: 'default',
                     meta_key_id: 'madek_core:title',
                     key_map: 'XMP-dc:Title')

    post_params = {
      media_entry: { media_file: fixture_file_upload(image_path, 'image/jpg') }
    }

    post :create, post_params, user_id: @user.id

    expect(response.redirect?).to be true
    expect(@user.unpublished_media_entries.count).to be 1
    media_entry = @user.unpublished_media_entries.first

    # media file #################################################################
    media_file = media_entry.media_file
    expect(media_file).to be
    extractor = MetadataExtractor.new(media_file.store_location)
    expect(media_file.meta_data).to eq extractor.to_hash
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

  it 'publish' do
    media_entry = \
      create :media_entry_with_image_media_file,
             creator: @user, responsible_user: @user, is_published: false

    @user.unpublished_media_entries.first
    expect(@user.unpublished_media_entries.first.id).to eq media_entry.id
    expect(media_entry.is_published).to be false

    post :publish, { id: media_entry.id }, user_id: @user.id
    expect(response.redirect?).to be true
    expect(flash[:success]).to eq 'Entry was published!'

    media_entry.reload
    expect(media_entry.is_published).to be true
    expect(@user.published_media_entries.first.id).to eq media_entry.id
    expect(@user.published_media_entries.count).to be 1
    expect(@user.unpublished_media_entries.count).to be 0
  end

  it 'delete' do
    media_entry = create :media_entry_with_image_media_file,
                         creator: @user, responsible_user: @user

    expect { delete :destroy, { id: media_entry.id }, user_id: @user.id }
      .to change { MediaEntry.count }.by(-1)

    expect(response).to redirect_to my_dashboard_path

  end

end
