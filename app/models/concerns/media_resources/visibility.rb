module Concerns
  module MediaResources
    module Visibility
      extend ActiveSupport::Concern

      included do
        scope :viewable_by_public, -> { where(get_metadata_and_previews: true) }

        def self.viewable_by_user(user)
          scope1 = viewable_by_public
          scope2 = entrusted_to_user(user)
          scope3 = user.send(model_name.plural)
          sql = "((#{scope1.to_sql}) UNION " \
                 "(#{scope2.to_sql}) UNION " \
                 "(#{scope3.to_sql})) AS #{table_name}"
          from(sql)
        end

        private

        def relational_collections_viewable_by_user(relation_kind, user)
          #  TODO: exclude self!
          send("#{relation_kind}_collections")
            .merge(Collection.viewable_by_user(user))
        end
      end

      def parent_collections_viewable_by_user(user)
        relational_collections_viewable_by_user(:parent, user)
      end

      def sibling_collections_viewable_by_user(user)
        relational_collections_viewable_by_user(:sibling, user)
      end
    end
  end
end
