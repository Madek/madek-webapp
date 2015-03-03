module Presenters
  module Groups
    class GroupShow < Presenter
      def initialize(group)
        @group = group
      end

      [:name, :institutional?, :institutional_group_name] \
        .each { |m| delegate m, to: :@group }

      def members
        @group
          .users
          .includes(:person)
          .map(&:person)
          .map { |p| Presenters::People::PersonIndex.new(p) }
      end
    end
  end
end
