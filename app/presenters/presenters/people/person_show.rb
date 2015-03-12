module Presenters
  module People
    class PersonShow < PersonCommon
      # TODO: show person.searchable? (it's supposed to be internal…)
      %w(first_name
         last_name
         pseudonym
         date_of_birth
         date_of_death).each { |m| delegate m.to_sym, to: :@app_resource }

      def bunch?
        @app_resource.is_bunch
      end

      def related_via_meta_data_media_resources
        # TODO: ANY [mediaResource*] WHERE ANY MetaDatum::Person IS @app_resource
        # - decide if the query is here or in Model
        Presenters::Shared::MediaResources::MediaResources.new \
          media_entries: [],
          collections: [],
          filter_sets: []
      end

    end
  end
end
