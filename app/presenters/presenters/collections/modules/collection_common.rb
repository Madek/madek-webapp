module Presenters
  module Collections
    module Modules
      module CollectionCommon
        extend ActiveSupport::Concern
        include Presenters::Shared::MediaResource::Modules::MediaResourceCommon

        def initialize(app_resource, user)
          fail 'TypeError!' unless app_resource.is_a?(Collection)
          @app_resource = app_resource
          @user = user
        end

        included do
          attr_reader :relations

          def url
            prepend_url_context_fucking_rails collection_path @app_resource
          end

          private

          def generic_thumbnail_url
            prepend_url_context_fucking_rails \
              ActionController::Base.helpers.image_path \
                Madek::Constants::Webapp::UI_GENERIC_THUMBNAIL[:collection]
          end

          def previews_helper(size:)
            media_entry = choose_media_entry_for_preview

            preview = if media_entry \
                      and media_entry.media_file.representable_as_image?
                        media_entry.media_file.preview(size)
                      end

            if preview.present?
              preview_path(preview)
            else
              generic_thumbnail_url
            end
          end

          def choose_media_entry_for_preview
            # TODO: this needs more cleverness.
            # possibly the 'recursive children' query could help…
            # we actually want to build a list of candidates and then select
            # the first one from the list which is representable as an image.
            # Right now, if the first entry is an image but the second is a pic,
            # we still show the generic thumbnail.
            c = @app_resource # the collection in question
            child_entries = c.media_entries.viewable_by_user_or_public(@user)
            child_collections = c.collections.viewable_by_user_or_public(@user)

            if child_entries.exists?
              return cover_or_first_media_entry(@app_resource)
            end

            if child_collections.exists?
              collection_with_preview_media_entry = child_collections.find do |c|
                cover_or_first_media_entry(c)
              end
              cover_or_first_media_entry(collection_with_preview_media_entry)
            end
          end

          def cover_or_first_media_entry(collection)
            return unless collection.present?

            # return the cover if there is one (and it is viewable!)
            if collection.cover.present?
              return MediaEntry
                .where(id: collection.cover.id).viewable_by_user_or_public.first
            end
            child_entries = collection.media_entries
              .viewable_by_user_or_public(@user)
            child_entries.first
          end
        end

      end
    end
  end
end
