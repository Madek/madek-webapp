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
      %w(first_name
         last_name
         pseudonym
         date_of_birth
         date_of_death).each { |m| delegate m.to_sym, to: :@app_resource }

      def bunch?
        @app_resource.is_bunch
      end

      alias_method :related_media_resources_via_meta_data,
                   :standard_media_resources
    end
  end
end
