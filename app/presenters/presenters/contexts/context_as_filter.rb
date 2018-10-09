module Presenters
  module Contexts
    class ContextAsFilter < Presenters::Contexts::ContextCommon

      def initialize(app_resource, values, position)
        super(app_resource)
        @values = values
        @position = position
      end

      attr_reader :position

      def filter_type
        :meta_data
      end

      def children(values = @values)
        values
          .group_by { |v| v['context_key_id'] }
          .map.with_index do |bundle, index|
            context_key_id, values = bundle
            children_attrs = ['uuid', 'count', 'label', 'type']
            context_key = Presenters::ContextKeys::ContextKeyCommon.new(
              ContextKey.find(context_key_id))
            {
              type: :MetaKey,
              uuid: context_key.meta_key_id,
              position: context_key.position,
              label: context_key.label || context_key.id,
              children: values.map { |v| v.slice(*children_attrs) },
              has_roles: context_key.meta_key.can_have_roles?
            }
          end
          .sort { |x, y| x[:position] <=> y[:position] }
      end
    end
  end
end
