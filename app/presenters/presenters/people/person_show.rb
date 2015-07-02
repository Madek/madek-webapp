module Presenters
  module People
    class PersonShow < PersonCommon
      def initialize(app_resource, user)
        super(app_resource)
        @user = user
        @filter = { meta_data:
                    [{ key: 'any',
                       value: uuid,
                       type: 'MetaDatum::People' }] }
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
        Pojo.new(
          media_entries: \
            Presenters::MediaEntries::MediaEntries
              .new(@user, MediaEntry.all, filter: @filter),
          collections: \
            Presenters::Collections::Collections
              .new(@user, Collection.all, filter: @filter),
          filter_sets: \
            Presenters::FilterSets::FilterSets
              .new(@user, FilterSet.all, filter: @filter)
        )
      end
    end
  end
end
