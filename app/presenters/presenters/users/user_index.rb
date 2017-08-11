module Presenters
  module Users
    class UserIndex < Presenters::Shared::AppResource
      delegate_to_app_resource :login

      def name
        @app_resource.person.to_s
      end

      def label
        name
      end

      def import_url
        new_media_entry_path
      end

    end
  end
end
