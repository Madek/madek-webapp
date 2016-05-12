module Presenters
  module Collections
    module Modules
      module CollectionCommon
        extend ActiveSupport::Concern
        include Presenters::Shared::MediaResource::Modules::MediaResourceCommon
        include Presenters::Shared::Modules::Favoritable

        def initialize(app_resource, user, list_conf: {})
          fail 'TypeError!' unless app_resource.is_a?(Collection)
          @app_resource = app_resource
          @user = user
          @recursed_collections_for_cover = []
          @_unused_list_conf = list_conf
        end

        def title
          @app_resource.title.presence or '<Collection has no title>'
        end

        def owner_pretty
          person = @app_resource.creator.person
          person.last_name + ', ' + person.first_name
        end

        def destroyable
          policy(@user).destroy?
        end

        def editable
          policy(@user).meta_data_update?
        end

        included do
          attr_reader :relations

          def url
            prepend_url_context collection_path @app_resource
          end

          def image_url
            get_image_preview(size: :medium) # NOTE: only shown as thumb!
          end

          private

          def generic_thumbnail_url
            prepend_url_context \
              ActionController::Base.helpers.image_path \
                Madek::Constants::Webapp::UI_GENERIC_THUMBNAIL[:collection]
          end

          def get_image_preview(size:)
            cover_media_entry = _choose_media_entry_for_preview
            preview = if cover_media_entry
                        Presenters::MediaFiles::MediaFile.new(
                          cover_media_entry, @user).previews
                          .try(:fetch, :images, nil).try(:fetch, size, nil)
                      end
            preview.present? ? preview.url : generic_thumbnail_url
          end

          def _choose_media_entry_for_preview(collection = @app_resource)
            cover = _cover_or_first_media_entry(collection)
            return cover if cover.present?
            # or try recursive search through children
            _cover_from_child_collections(collection)
          end

          def _cover_from_child_collections(collection)
            return if @recursed_collections_for_cover.include?(collection)
            @recursed_collections_for_cover << collection
            # NOTE: two loops because we try all cheaper queries first
            child_collections = collection
              .collections.viewable_by_user_or_public(@user)
              .reorder(created_at: :desc)

            if child_collections.exists?
              # get cover from first level of collection
              child_collections.each do |c|
                cover = _cover_or_first_media_entry(c)
                return cover if cover.present?
              end
              # recurse if not found on this level (and not already searched)
              child_collections.each do |c|
                cover = _cover_from_child_collections(c)
                return cover if cover.present?
              end
              nil # return nil if nothing found anywhere
            end
          end

          def _cover_or_first_media_entry(collection)
            return unless collection.present?

            # return the configured cover if there is one (and it is viewable!)
            if collection.cover.present?
              cover = MediaEntry.viewable_by_user_or_public(@user)
                .find_by(id: collection.cover.id)
              return cover if cover.present?
            end

            # otherwise return the first image-like entry
            collection.media_entries
              .viewable_by_user_or_public(@user)
              .reorder(created_at: :desc)
              .each do |e|
                  return e if e.media_file.representable_as_image?
              end
            nil # return nil if nothing found
          end
        end

      end
    end
  end
end
