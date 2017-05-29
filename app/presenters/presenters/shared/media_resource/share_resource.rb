module Presenters
  module Shared
    module MediaResource
      class ShareResource < Presenters::Shared::AppResource

        def initialize(app_resource, user, base_url)
          super(app_resource)
          @user = user
          @base_url = base_url
        end

        def title
          @app_resource.title
        end

        def resource_url
          prepend_url_context(
            send("#{underscore}_path", @app_resource)
          )
        end

        def uuid_url
          @base_url + prepend_url_context(
            send("#{underscore}_path", @app_resource.id)
          )
        end

        def primary_custom_url
          primary_urls = @app_resource.custom_urls.select &:is_primary

          return if primary_urls.empty?

          @base_url + prepend_url_context(
            send("#{underscore}_path", primary_urls[0].id)
          )
        end

        private

        def underscore
          @app_resource.class.name.underscore
        end
      end
    end
  end
end
