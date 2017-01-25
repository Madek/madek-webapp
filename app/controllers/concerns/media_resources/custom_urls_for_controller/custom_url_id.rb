module Concerns
  module MediaResources
    module CustomUrlsForController # avoiding name clash with DL
      module CustomUrlId
        extend ActiveSupport::Concern

        EXCLUDE_IDS = %w(
          upload
          batch_edit_meta_data_by_context
          batch_edit_meta_data_by_vocabularies
          batch_meta_data
          batch_select_add_to_set
          batch_edit_permissions
          batch_update_permissions
        )

        def singular_model_name_id
          @singular_model_name_id ||= \
            "#{model_klass.model_name.singular}_id".to_sym
        end

        def find_primary_custom_url_for_uuid(mr_id)
          CustomUrl.find_by Hash[singular_model_name_id, mr_id, :is_primary, true]
        end

        def valid_uuid?(uuid)
          begin
            UUIDTools::UUID.parse(uuid).valid?
          rescue
            false
          end
        end

        def require_media_resource_id!
          begin
            params.require(singular_model_name_id)
          rescue
            params.require(:id)
          end
        end

        def id_param
          # translate a custom primary id to an UUID
          id = require_media_resource_id!
          if valid_uuid?(id)
            id
          else
            CustomUrl
              .find_by!(id: id, is_primary: true)
              .send(singular_model_name_id)
          end
        end

        def after_query_params
          @after_query_params ||= request_fullpath.split('?').second
        end

        def media_resource_id
          before_query_params = request_fullpath.split('?').first
          resource_and_format = before_query_params.split('/').third
          return unless resource_and_format
          @media_resource_id, @format = \
            before_query_params.split('/').third.split('.')

          not EXCLUDE_IDS.include?(@media_resource_id) \
            and @media_resource_id
        end

        def fullpath_with_media_resource_id(id)
          fp_parts_before_query_params = request_fullpath.split('/')
          fp_parts_before_query_params[2] = id
          fp_parts_before_query_params = fp_parts_before_query_params.join('/')
          if @after_query_params
            url = if @format
                    fp_parts_before_query_params + '.' + @format
            else
              fp_parts_before_query_params
            end
            url + '?' + @after_query_params
          else
            fp_parts_before_query_params
          end
        end

        def check_and_redirect_with_custom_url
          # skip if there isn't media_resource_id, otherwise:
          # 1) if media_resource_id is an UUID and there is other
          # primary custom URL defined, redirect to the custom one
          # 2) if the media_resource_id is a custom one, but it is
          # not primary, redirect to the UUID one
          # 3) otherwise do nothing
          # for 1) and 2) preserve subroute

          if media_resource_id
            if valid_uuid?(media_resource_id)
              if primary_custom_url = \
                  find_primary_custom_url_for_uuid(media_resource_id)
                redirect_to \
                  fullpath_with_media_resource_id \
                    primary_custom_url.id
              end
            elsif not (custom_url = CustomUrl.find(media_resource_id)).is_primary?
              redirect_to \
                fullpath_with_media_resource_id \
                  custom_url.send(singular_model_name_id)
            end
          end
        end

        included do
          before_action :check_and_redirect_with_custom_url
        end

        private

        def request_fullpath
          root = Madek::Application.config.action_controller.relative_url_root
          if root.present?
            request.fullpath.slice(root)
          else
            request.fullpath
          end
        end

      end
    end
  end
end
