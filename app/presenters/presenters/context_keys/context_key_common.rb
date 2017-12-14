module Presenters
  module ContextKeys
    class ContextKeyCommon < Presenters::Shared::AppResource

      def initialize(app_resource)
        super(app_resource)
        @meta_key = Presenters::MetaKeys::MetaKeyCommon.new(@app_resource.meta_key)
      end

      delegate_to_app_resource(
        :position,
        :is_required,
        :length_min,
        :length_max,
        :meta_key_id)

      # for simple display purposes, we provide the 3 "shadowed" props,
      # for everything else 'meta_key' is provided.

      attr_reader :meta_key

      def description
        @app_resource.description(I18n.locale) or @meta_key.description
      end

      def label
        @app_resource.label(I18n.locale) or @meta_key.label or @meta_key.uuid
      end

      def hint
        @app_resource.hint(I18n.locale) or @meta_key.hint
      end
    end
  end
end
