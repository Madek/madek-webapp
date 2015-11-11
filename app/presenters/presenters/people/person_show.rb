module Presenters
  module People
    class PersonShow < PersonCommon
      def initialize(app_resource, user, list_conf: nil)
        super(app_resource)
        @user = user
        @list_conf = list_conf
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
        # The base filter for this view.
        # CAN NOT be mutateded by the UI (always applied first)
        base_filter = { meta_data: [
          { key: 'any', value: self.uuid, type: 'MetaDatum::People' }] }

        # TODO: MultiMediaResourceBox
        resources = MediaEntry.filter_by(base_filter)
        Presenters::MediaEntries::MediaEntries.new(
          resources, @user, list_conf: @list_conf)
      end
    end
  end
end
