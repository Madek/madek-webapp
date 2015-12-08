module Presenters
  module MetaKeys
    class MetaKeyAsFilter < Presenters::MetaKeys::MetaKeyCommon

      def initialize(app_resource, scope, tree)
        super(app_resource)
        @scope = scope
        @tree = tree
      end

      # NOTE: only some types implemented!

      # if filtering for multiple children is possible
      def multi
        # FIXME: determine by config of MetaKey
        true
      end

      # all resources that exist as values for given MetaKey in scope
      def children(meta_key = @app_resource, scope = @scope, tree = @tree)
        return unless tree
        case meta_key.meta_datum_object_type.demodulize
        when 'Keywords'
          keywords(meta_key, scope)
        end
        # TODO: when 'People'
        #   people(meta_key, scope)
      end

      private

      def keywords(meta_key, scope)
        # FIXME: reduce this to only Keywords used in scope!
        meta_key.keywords.map do |k|
          Presenters::Keywords::KeywordAsFilter.new(k, scope)
        end
      end

      # def people(_meta_key, _scope)
      #   # TODO: get a (uniq) list of all people mentioned in any metadatum
      #   # on any resource in scope
      # end

    end
  end
end
