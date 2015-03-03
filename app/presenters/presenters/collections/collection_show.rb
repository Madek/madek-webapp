module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::MediaResources::MediaResourceShow
      include Presenters::Collections::Modules::CollectionCommon

      def initialize(resource, user)
        super(resource, user)
        @relations = \
          Presenters::Collections::CollectionRelations.new(@resource, @user)
      end

      def preview_thumb_url
        ActionController::Base.helpers.image_path \
          ::UI_GENERIC_THUMBNAIL[:collection]
      end

      def highlights_thumbs
        @resource \
          .media_entries
          .highlights
          .map { |me| Presenters::MediaEntries::MediaEntryIndex.new(me, @user) }
      end

      # These are the MediaResources that are "inside" the Collection:
      # TODO: MediaResourcesPresenter
      def child_media_resources
        {
          media_entries:
            @resource \
              .media_entries
              .map do |me|
                Presenters::MediaEntries::MediaEntryIndex.new(me, @user)
              end,

          collections:
            @resource \
              .collections
              .map do |c|
                Presenters::Collections::CollectionIndex.new(c, @user)
              end,

          filter_sets:
            @resource \
              .filter_sets
              .map do |fs|
                Presenters::FilterSets::FilterSetIndex.new(fs, @user)
              end
        }
      end
    end
  end
end
