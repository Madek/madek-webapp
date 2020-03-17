module Presenters
  module People
    class PersonEdit < Presenters::People::PersonCommon
      def initialize(app_resource, user)
        super(app_resource)
        @user = user
      end

      delegate_to_app_resource :first_name, :last_name, :pseudonym, :description,
                               :external_uris, :to_s

      def actions
        {
          update: {
            url: person_path(@app_resource),
            method: 'PATCH'
          },
          cancel: {
            url: person_path(@app_resource)
          }
        }
      end
    end
  end
end
