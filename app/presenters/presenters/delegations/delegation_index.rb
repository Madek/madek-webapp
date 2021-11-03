module Presenters
  module Delegations
    class DelegationIndex < Presenters::Shared::AppResource
      def name
        "#{@app_resource.name}#{I18n.t(:app_autocomplete_user_delegation_postfix)}"
      end

      def url
      end

      def entrusted_media_resources_count
        Delegation.with_resources_count.where(id: @app_resource.id).first&.resources_count
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
