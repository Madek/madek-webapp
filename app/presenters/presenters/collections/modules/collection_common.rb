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

        def title
          @app_resource.title.presence or '<Collection has no title>'
        end

        def owner
          person = @app_resource.creator.person
          person.last_name + ', ' + person.first_name
        end

        def created_at
          @app_resource.created_at.strftime('%d.%m.%Y')
        end

        included do
          attr_reader :relations
        end

      end
    end
  end
end
