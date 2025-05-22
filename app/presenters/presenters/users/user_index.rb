module Presenters
  module Users
    class UserIndex < Presenters::Shared::AppResource
      delegate_to_app_resource :login, :is_deactivated

      def name
        if is_deactivated
          "usr-#{@app_resource.id[0, 8]}"
        else
          @app_resource.to_s
        end
      end

      def label
        name
      end

      def autocomplete_label
        @app_resource.email.present? ? "#{label} <#{@app_resource.email}>" : label
      end

      def import_url
        new_media_entry_path
      end

    end
  end
end
