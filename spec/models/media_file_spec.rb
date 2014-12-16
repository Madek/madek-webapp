require 'spec_helper'

describe MediaFile do

  context 'Creation' do
    it 'should be producible by a factory' do
      expect { FactoryGirl.create :media_file }.not_to raise_error
    end

    it 'validates presence of uploader' do
      expect { FactoryGirl.create :media_file, uploader: nil }.to raise_error
    end
  end

  context '.incomplete_encoded_videos' do
    it 'returns media files with no videos previews' do
      media_file = FactoryGirl.create(:media_file_for_movie)
      image_preview = FactoryGirl.create(:preview, content_type: 'image/jpeg', media_file: media_file)

      expect(media_file.previews).to include(image_preview)
      expect(image_preview.media_type).to be == 'image'
      expect(MediaFile.incomplete_encoded_videos).to include(media_file)
    end
  end

end
