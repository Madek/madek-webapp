module Presenters
  module Groups
    class GroupShow < Presenters::Shared::AppResource
      [:name, :institutional?, :institutional_group_name] \
        .each { |m| delegate m, to: :@app_resource }

      def members
        @app_resource
          .users
          .includes(:person)
          .map(&:person)
          .map { |p| Presenters::People::PersonIndex.new(p) }
      end
    end
  end
end
