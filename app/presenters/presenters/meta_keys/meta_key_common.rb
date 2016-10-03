module Presenters
  module MetaKeys
    class MetaKeyCommon < Presenters::Shared::AppResource
      delegate_to_app_resource(:description,
                               :hint,
                               :vocabulary_id,
                               :allowed_people_subtypes,
                               :position)

      def initialize(app_resource)
        super(app_resource)

        # props for special types

        if @app_resource.can_have_keywords?

          define_singleton_method :is_extensible do
            @app_resource.is_extensible_list? ? true : false # coerce to bool
          end

          define_singleton_method :alphabetical_order do
            @app_resource.keywords_alphabetical_order
          end
        end
      end

      def label
        @app_resource.label or @app_resource.id.split(':').last.humanize
      end

      def value_type
        @app_resource.meta_datum_object_type
      end

    end
  end
end
