module Presenters
  module MediaEntries
    module Modules
      module MediaEntryCommon
        extend ActiveSupport::Concern
        include Presenters::Shared::MediaResource::Modules::MediaResourceCommon
        include Presenters::Shared::Modules::Favoritable

        def initialize(app_resource, user, list_conf: {})
          fail 'TypeError!' unless app_resource.is_a?(MediaEntry)

          # FIXME: because MediaEntry *might* be instantiated via
          # `vw_media_resources` view we *might* need to re-init…
          @app_resource = if app_resource.respond_to?(:is_published)
            app_resource
          else
            ::MediaEntry.find(app_resource.id)
          end

          @user = user
          @list_conf = list_conf
          @media_file = \
            if @app_resource.try(:media_file).present?
              Presenters::MediaFiles::MediaFile.new(@app_resource, @user)
            end

          @p_media_entry =
            Presenters::MediaEntries::PresMediaEntry.new(@app_resource)
        end

        def destroyable
          policy(@user).destroy?
        end

        def editable
          policy(@user).meta_data_update?
        end

        def permissions_editable
          policy(@user).permissions_edit?
        end

        def invalid_meta_data
          # NOTE: this is needed to determine if batch editing is allowed
          # In general, we can check for drafts if publishing is possible;
          # and for non-drafts if the validation changed since publishing!
          true unless @app_resource.valid?
        end

        included do

          attr_reader :media_file

          def title
            @p_media_entry.title
          end

          def media_type
            @app_resource.try(:media_file).try(:media_type)
          end

          def published?
            @app_resource.is_published
          end

          def url
            prepend_url_context media_entry_path(@app_resource)
          end

        end
      end
    end
  end
end
