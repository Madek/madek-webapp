module Presenters
  module People
    class PersonShow < PersonCommon
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
        @app_resource.is_bunch
      end

      def related_media_resources_via_meta_data
        Presenters::Shared::MediaResources::MediaResources.new \
          @user,
          filter: { meta_data:
                    [{ key: 'any',
                       value: uuid,
                       type: 'MetaDatum::People' }] }
      end
    end
  end
end
