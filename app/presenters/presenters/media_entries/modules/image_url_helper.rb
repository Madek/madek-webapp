module Presenters
  module MediaEntries
    module Modules
      module ImageUrlHelper
        # Gets image URL for a specific size with fallback to next larger available size
        def image_url_for_size(size)
          return nil unless @app_resource.try(:media_file).present?
          
          # Get the cached preview hash from MediaFile presenter
          imgs = Presenters::MediaFiles::MediaFile.new(@app_resource, @user)
            .try(:previews).try(:fetch, :images, nil)
          
          return nil if imgs.blank?
          
          # Try to get the wanted size first
          img = imgs.fetch(size, nil)
          return img.url if img.present?
          
          # Fallback: find next larger size (sizes are ordered largest to smallest)
          sizes = Madek::Constants::THUMBNAILS.keys
          wanted_index = sizes.index(size)
          return nil unless wanted_index
          
          # Search backward in the array (toward larger sizes)
          (wanted_index - 1).downto(0) do |i|
            larger_size = sizes[i]
            img = imgs.fetch(larger_size, nil)
            return img.url if img.present?
          end
          
          nil
        end
      end
    end
  end
end
