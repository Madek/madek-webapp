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
          @_unused_list_conf = list_conf
        end

        def destroyable
          policy_for(@user).destroy?
        end

        def editable
          policy_for(@user).meta_data_update?
        end

        def permissions_editable
          policy_for(@user).permissions_edit?
        end

        def responsibility_transferable
          policy_for(@user).edit_transfer_responsibility?
        end

        included do
          def url
            prepend_url_context collection_path @app_resource
          end

          def image_url
            # NOTE: only shown as thumb!
            if @async_cover
              prepend_url_context cover_collection_path(@app_resource,
                                                        size: :medium)
            else
              CollectionThumbUrl.new(@app_resource, @user).get(size: :medium)
            end
          end
        end
      end
    end
  end
end
