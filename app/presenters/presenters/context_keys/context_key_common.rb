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
      # Fallbacks prefer a translated meta_key over a non-translated self prop.

      attr_reader :meta_key

      def description
        @app_resource.description(I18n.locale) \
          or @app_resource.meta_key.description(I18n.locale) \
          or @app_resource.description \
          or @meta_key.description
      end

      def label
        @app_resource.label(I18n.locale) \
          or @app_resource.meta_key.label(I18n.locale) \
          or @app_resource.label \
          or @meta_key.label # already makes sure to *always* display something
      end

      def hint
        @app_resource.hint(I18n.locale) \
          or @app_resource.meta_key.hint(I18n.locale) \
          or @app_resource.hint \
          or @meta_key.hint
      end

      def documentation_url
        @app_resource.sanitize_documentation_url(I18n.locale) \
          or @app_resource.meta_key.sanitize_documentation_url(I18n.locale) \
          or @app_resource.sanitize_documentation_url \
          or @meta_key.documentation_url
      end
    end
  end
end
