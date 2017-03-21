module Presenters
  module MediaEntries
    module Modules
      module MediaEntryCommon
        extend ActiveSupport::Concern
        include Presenters::Shared::MediaResource::Modules::MediaResourceCommon
        include Presenters::Shared::Modules::Favoritable

        def initialize(app_resource, user, list_conf: {}, load_meta_data: false)
          fail 'TypeError!' unless app_resource.is_a?(MediaEntry)

          # FIXME: because MediaEntry *might* be instantiated via
          # `vw_media_resources` view we *might* need to re-init…
          @app_resource = if app_resource.respond_to?(:is_published)
            app_resource
          else
            ::MediaEntry.unscoped.find(app_resource.id)
          end
          @user = user
          @list_conf = list_conf

          @load_meta_data = load_meta_data
        end

        def destroyable
          policy_for(@user).destroy?
        end

        def editable
          policy_for(@user).meta_data_update?
        end

        def permissions_editable
          policy_for(@user).permissions_edit? && @app_resource.is_published
        end

        def responsibility_transferable
          policy_for(@user).edit_transfer_responsibility?
        end

        def invalid_meta_data
          # NOTE: this is needed to determine if batch editing is allowed
          # In general, we can check for drafts if publishing is possible;
          # and for non-drafts if the validation changed since publishing!
          true unless @app_resource.valid?
        end

        included do

          def media_type
            @app_resource.try(:media_file).try(:media_type)
          end

          def published?
            @app_resource.is_published
          end

          def url
            prepend_url_context media_entry_path(@app_resource)
          end

          def media_file
            return unless @app_resource.try(:media_file).present?
            @media_file ||= \
              Presenters::MediaFiles::MediaFile.new(@app_resource, @user)
          end

        end
      end
    end
  end
end
