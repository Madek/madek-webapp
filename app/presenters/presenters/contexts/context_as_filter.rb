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
        max_people = 10
        values
          .group_by { |v| v['context_key_id'] }
          .map.with_index do |bundle, index|
            context_key_id, values = bundle
            children_attrs = ['uuid', 'count', 'label', 'type']
            context_key = Presenters::ContextKeys::ContextKeyCommon.new(
              ContextKey.find(context_key_id))
            tmp_children = values.map { |v| v.slice(*children_attrs) }

            # Limit People
            too_many_hits = (context_key.meta_key.value_type == 'MetaDatum::People') &&
                            tmp_children.filter{ |v| v["type"] == "person" }.count > max_people
            tmp_children = if too_many_hits
                             tmp_children.filter{ |v| v["type"] == "person" }.take(max_people) +
                               tmp_children.filter{ |v| v["type"] == "role" }
                           else
                             tmp_children
                           end

            {
              type: :MetaKey,
              uuid: context_key.meta_key_id,
              position: context_key.position,
              label: context_key.label || context_key.id,
              children: tmp_children,
              context_key_id: context_key_id,
              meta_datum_object_type: context_key.meta_key.value_type,
              too_many_hits: too_many_hits ? true : nil
            }
          end
          .sort { |x, y| x[:position] <=> y[:position] }
      end
    end
  end
end
