module Presenters
  module Shared
    module Resources
      class Relations < Presenter
        attr_reader :has_any

        def initialize(resource, user)
          @resource = resource
          @user = user
          @has_any = \
            api
              .reject { |m| m == :has_any }
              .any? { |m| not send(m).empty? }
        end

        def parent_collections
          collections(:parent)
        end

        def sibling_collections
          collections(:sibling)
        end

        private

        def collections(kind)
          var = "@#{kind.to_s.pluralize}"
          instance_variable_get(var) \
            or instance_variable_set \
              var,
              @resource.send("#{kind}_collections_viewable_by_user", @user)
                .map { |c| Presenters::Collections::CollectionThumb.new(c, @user) }
        end
      end
    end
  end
end
