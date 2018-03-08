module Modules
  module Resources
    module ResourceConfidentialLinks
      extend ActiveSupport::Concern

      included do
        skip_before_action :check_and_redirect_with_custom_url,
                           if: :action_handled_by_confidential_links?
      end

      def confidential_links
        resource = resource_class.find(id_param)
        auth_authorize(resource)
        respond_with(
          @get = confidential_link_presenter.new(resource, current_user))
      end

      private

      def resource_class
        controller_name
          .camelize
          .singularize
          .constantize
      end

      def confidential_link_presenter
        [
          'Presenters',
          controller_name.camelize,
          "#{resource_class.name}ConfidentialLinks"
        ]
          .join('::')
          .constantize
      end

      def action_handled_by_confidential_links?
        action_name == 'show_by_confidential_link' ||
          action_name == 'show' && params[:access].present?
      end
    end
  end
end
