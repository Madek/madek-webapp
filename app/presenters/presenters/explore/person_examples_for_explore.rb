module Presenters
  module Explore
    class PersonExamplesForExplore < Presenters::Explore::PersonIndexForExplore

      include Presenters::Explore::Modules::NewestEntryWithImage

      def initialize(app_resource, user, with_entries)
        super(app_resource, user)
        @with_entries = with_entries
      end

      def media_entries
        return unless @with_entries
        newest_media_entry_with_image_file_for_person_and_user(
          @app_resource.id, @user).map do |media_entry|
          Presenters::Explore::KeywordExample.new(media_entry, @user)
        end
      end
    end
  end
end
