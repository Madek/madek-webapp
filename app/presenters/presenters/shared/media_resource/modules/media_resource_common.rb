module Presenters
  module Shared
    module MediaResource
      module Modules
        module MediaResourceCommon
          extend ActiveSupport::Concern
          include Presenters::Shared::MediaResource::Modules::Responsible

          def title
            _resource_title(@app_resource)
          end

          def created_at_pretty
            @app_resource.created_at.strftime('%d.%m.%Y')
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

          def authors_pretty
            authors = @app_resource.meta_data.find_by(
              meta_key_id: 'madek_core:authors')
            authors ? authors.value.map(&:to_s).join(', ') : ''
          end

          def destroyable
            false
          end

          def editable
            false
          end

        end
      end
    end
  end
end
