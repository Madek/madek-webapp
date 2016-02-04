module Presenters
  module ContextKeys
    class ContextKeyCommon < Presenters::Shared::AppResource

      def initialize(app_resource)
        super(app_resource)
        @meta_key = Presenters::MetaKeys::MetaKeyCommon.new(@app_resource.meta_key)
      end

      delegate_to_app_resource(
        :position,
        :meta_key_id)

      # for simple display purposes, we provide the 3 "shadowed" props,
      # for everything else 'meta_key' is provided.

      attr_reader :meta_key

      def description
        @app_resource.description or @meta_key.description
      end

      def label
        @app_resource.label or @meta_key.label
      end

      def hint
        @app_resource.hint or @meta_key.hint
      end

    end
  end
end
