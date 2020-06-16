module Presenters
  module Shared
    module MediaResource
      module Modules
        module MediaResourceCommon
          extend ActiveSupport::Concern
          include Presenters::Shared::MediaResource::Modules::Responsible

          included do
            delegate_to_app_resource :title
          end

          def created_at_pretty
            @app_resource.created_at
              .in_time_zone(AppSetting.first.time_zone)
              .strftime('%d.%m.%Y')
          end

          def portrayed_object_date_pretty
            date = @app_resource.meta_data.find_by(
              meta_key_id: 'madek_core:portrayed_object_date')
            if date
              return date.string
            else
              return ''
            end
          end

          def copyright_notice_pretty
            copyright = @app_resource.meta_data.find_by(
              meta_key_id: 'madek_core:copyright_notice')
            if copyright
              return copyright.string
            else
              return ''
            end
          end

          def authors_pretty
            @app_resource.authors || ''
          end

          def destroyable
            false
          end

          def editable
            false
          end

          def collection_manageable
            false
          end

          def clipboard_url
            my_dashboard_section_path(:clipboard)
          end

          def used_confidential_access_token
            return unless @app_resource
                           .respond_to?(:accessed_by_confidential_link)

            token = @app_resource.accessed_by_confidential_link
            return token if token.is_a?(String) && token.present?
          end
        end
      end
    end
  end
end
