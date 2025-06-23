module Presenters
  module Delegations
    class DelegationIndex < Presenters::Shared::AppResource
      def initialize(app_resource, with_resources_count: false)
        super(app_resource)
        @with_resources_count = with_resources_count
      end

      def name
        "#{@app_resource.name}#{I18n.t(:app_autocomplete_user_delegation_postfix)}"
      end

      def url
      end

      def entrusted_media_resources_count
        if @with_resources_count
          Delegation.with_resources_count.where(id: @app_resource.id).first&.resources_count
        end
      end

      def edit_url
      end

      alias_method :label,              :name
      alias_method :autocomplete_label, :name
      alias_method :detailed_name,      :name
      alias_method :resource_type,      :type
    end
  end
end
