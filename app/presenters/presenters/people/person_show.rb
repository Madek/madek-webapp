module Presenters
  module People
    class PersonShow < PersonCommon

      include Presenters::Shared::MediaResources::Modules::\
              MediaResourcesHelpers

      def initialize(app_resource, user)
        super(app_resource)
        @user = user
      end

      # TODO: show person.searchable? (it's supposed to be internal…)
      delegate_to_app_resource :first_name,
                               :last_name,
                               :pseudonym,
                               :date_of_birth,
                               :date_of_death

      def bunch?
        @app_resource.bunch?
      end

      alias_method :related_media_resources_via_meta_data,
                   :standard_media_resources
    end
  end
end
