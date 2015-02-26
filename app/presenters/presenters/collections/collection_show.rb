module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::Resources::ResourceShow
      include Presenters::Shared::Resources::Modules::Responsible

      def initialize(resource, user)
        super(resource, user)
        @relations = \
          Presenters::Collections::Relations.new(@resource, @user)
      end

      def preview_thumb_url
        ActionController::Base.helpers.image_path \
          ::UI_GENERIC_THUMBNAIL[:collection]
      end

      def highlights_thumbs
        @resource \
          .media_entries
          .highlights
          .map { |me| Presenters::MediaEntries::MediaEntryThumb.new(me, @user) }
      end

      def poly_resources
        {
          media_entries:
            @resource \
              .media_entries
              .map do |me|
                Presenters::MediaEntries::MediaEntryThumb.new(me, @user)
              end,

          collections:
            @resource \
              .collections
              .map do |c|
                Presenters::Collections::CollectionThumb.new(c, @user)
              end,

          filter_sets:
            @resource \
              .filter_sets
              .map do |fs|
                Presenters::FilterSets::FilterSetThumb.new(fs, @user)
              end
        }
      end
    end
  end
end
