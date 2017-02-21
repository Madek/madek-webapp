module Modules
  module Collections
    module Create
      extend ActiveSupport::Concern

      include Modules::Collections::Store

      def create
        auth_authorize Collection
        title = params[:collection_title]

        if title.present?
          create_render_success(title)
        else
          create_render_title_mandatory
        end
      end

      private

      def create_render_success(title)
        collection = store_collection(title)
        respond_to do |format|
          format.json do
            render(json: { forward_url: collection_path(collection) })
          end
          format.html do
            redirect_to(
              collection_path(collection),
              flash: { success: I18n.t(:collection_new_flash_successful) })
          end
        end
      end

      def create_render_title_mandatory
        respond_to do |format|
          format.json do
            render(
              json: {
                errors: {
                  title_mandatory: I18n.t(:collection_new_flash_title_needed)
                }
              },
              status: :bad_request
            )
          end
          format.html do
            redirect_to(
              my_new_collection_path,
              flash: { error: I18n.t(:collection_new_flash_title_needed) })
          end
        end
      end

    end
  end
end
