module Presenters
  module MediaEntries
    class MediaEntrySiblings < Presenters::Shared::AppResourceWithUser
      def siblings
        @app_resource.sibling_media_entries(@user).map do |item|
          item[:collection] = presenterify(item[:collection])
          item[:media_entries] = item[:media_entries].map { |me| presenterify(me) }
          item
        end
      end

      private

      def presenterify(resource)
        klass_name = resource.class.name
        klass = "Presenters::#{klass_name.pluralize}::#{klass_name}Index".constantize
        klass.new(resource, @user).dump(sparse_spec: wanted_props(klass_name))
      end

      def wanted_props(klass_name)
        {
          'Collection' => %i(uuid url title),
          'MediaEntry' => %i(uuid url title image_url media_type)
        }
          .fetch(klass_name)
          .map { |k| [k, {}] }
          .to_h
      end
    end
  end
end
