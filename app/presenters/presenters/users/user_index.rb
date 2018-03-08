module Presenters
  module Users
    class UserIndex < Presenters::Shared::AppResource
      delegate_to_app_resource :login

      def name
        if @app_resource.is_deactivated
          I18n.t(:user_name_deactivated)
        else
          @app_resource.person.to_s
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
