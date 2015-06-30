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
    meta_key = FactoryGirl.create(:meta_key_text)
    image_path = Rails.root.join('engines', 'datalayer',
                                 'spec', 'images', 'test.png')
    post_params = \
      { media_entry: \
        { responsible_user_id: @user.id,
          creator_id: @user.id,
          media_file: {
            file: fixture_file_upload(image_path, 'image/png'),
            uploader_id: @user.id
          },
          meta_data: [
            { _key: meta_key.id,
              _value: { type: meta_key.meta_datum_object_type,
                        content: ['test'] }
            }
          ]
        }
      }

    post :create, post_params, user_id: @user.id
    expect(response.redirect?).to be true
    expect(@user.media_entries.count).to be 1
    media_entry = @user.media_entries.first
    media_file = media_entry.media_file
    expect(media_file).to be

    folder_path = \
      "#{Rails.root}/db/media_files/test/attachments/#{media_file.guid.first}/"
    expect(File.exist? "#{folder_path}#{media_file.guid}").to be true

    THUMBNAILS.keys.each do |thumb_size|
      next if thumb_size == :maximum
      expect(File.exist? "#{folder_path}#{media_file.guid}_#{thumb_size}.jpg")
        .to be true
    end
    expect(media_file.previews.size).to be == THUMBNAILS.size

    expect(media_entry.meta_data.exists?).to be true
  end

  it_performs 'authorization'
end
