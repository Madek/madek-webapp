require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'
require_relative '../shared/basic_data_helper_spec'
require_relative '../shared/meta_data_helper_spec'
include BasicDataHelper
include MetaDataHelper

feature 'Resource: MediaEntry' do
  describe 'Previews on Detail view' do

    example 'Image: shows "large" image preview and links to "largest" image' do
      entry = FactoryGirl.create(
        :media_entry_with_image_media_file,
        get_metadata_and_previews: true)

      # NOTE: factory image is not large enough to
      # determine 'largest', check all:
      largest_preview = entry.media_file.previews.reorder(width: :DESC).first
      largest_previews = entry.media_file.previews
        .where(width: largest_preview.width)
        .map { |p| preview_path(p) }

      visit media_entry_path(entry)

      preview = page.find('.ui-media-overview-preview')
      preview_link = preview.find('a:not(.ui-magnifier)')
      preview_img = preview_link.find('img')

      expect(URI.parse(preview_link[:href]).path).to eq(
        export_media_entry_path(entry))
      expect(largest_previews) # see above
        .to include(URI.parse(preview_img[:src]).path)
    end

    example 'PDF: shows image preview and links to (original) PDF' do
      # NOTE: need to use Personas DB as there is no factory with a real PDF!

      # entry = FactoryGirl.create(
      #   :media_entry_with_document_media_file,
      #   get_metadata_and_previews: true,
      #   get_full_size: true)
      entry = MediaEntry.find('c50bc33d-626b-43ac-b297-8725ac8a152b')
      entry.update_attributes!(get_full_size: true)

      large_preview = preview_path(
        entry.media_file.previews.where(thumbnail: :large).first)
      original_file = media_file_path(entry.media_file)

      visit media_entry_path(entry)

      preview = page.find('.ui-media-overview-preview')
      preview_link = preview.find('a')
      preview_img = preview_link.find('img')

      expect(URI.parse(preview_img[:src]).path).to eq(large_preview)
      expect(URI.parse(preview_link[:href]).path).to eq(original_file)
    end
  end

end
