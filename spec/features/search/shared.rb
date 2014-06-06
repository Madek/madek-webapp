module Features
  module Search
    module Shared

      def create_a_media_entry
        FactoryGirl.create :media_entry_with_image_media_file, 
          user: @current_user
      end

      def set_media_resource_title media_resource , title
        media_resource.meta_data \
          .create meta_key: MetaKey.find_by_id(:title), value: title
      end

    end
  end
end
