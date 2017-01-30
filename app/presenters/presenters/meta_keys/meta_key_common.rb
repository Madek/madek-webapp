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

        if @app_resource.meta_datum_object_type == 'MetaDatum::Text'
          define_singleton_method :text_type do
            @app_resource.text_type # is 'line' or 'block'
          end
        end
      end

      def label
        @app_resource.label or @app_resource.id.split(':').last.humanize
      end

      def value_type
        @app_resource.meta_datum_object_type
      end

      def text_type
        @app_resource.try(:text_type)
      end

      def scope
        [['media_entries', 'Entries'], ['collections', 'Sets']] # [[class, name]]
          .select { |type| @app_resource.send("is_enabled_for_#{type[0]}") }
          .map(&:second)
      end

    end
  end
end
