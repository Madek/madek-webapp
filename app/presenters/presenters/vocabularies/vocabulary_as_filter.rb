module Presenters
  module Vocabularies
    class VocabularyAsFilter < Presenters::Vocabularies::VocabularyCommon

      def initialize(app_resource, scope, tree, position)
        super(app_resource)
        @scope = scope
        @tree = tree
        @position = position
      end

      attr_reader :position

      def filter_type
        :meta_data
      end

      def children(vocabulary = @app_resource, scope = @scope, tree = @tree)
        return unless tree

        # TODO: select only the keys which are used in scope
        supported_types = [MetaDatum::Keywords] # TODO: << MetaDatum::People
        vocabulary.meta_keys
          .where(meta_datum_object_type: supported_types)
          .sort_by(&:position)
          .map do |mk|
            children = tree.fetch(mk.id.to_sym, false)
            Presenters::MetaKeys::MetaKeyAsFilter.new(mk, scope, children)
          end
      end

    end
  end
end
