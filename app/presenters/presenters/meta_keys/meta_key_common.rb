module Presenters
  module MetaKeys
    class MetaKeyCommon < Presenters::Shared::AppResource
      delegate_to_app_resource(:description,
                               :hint,
                               :vocabulary_id,
                               :position)

      def label
        @app_resource.label or @app_resource.id.split(':').last.humanize
      end

      # def type
      #   @app_resource.meta_datum_object_type
      # end

      def value_type
        @app_resource.meta_datum_object_type
      end

    end
  end
end
