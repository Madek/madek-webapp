module Presenters
  module XmpNamespaces
    class XmpNamespaceShow < Presenter
      def initialize(namespace, user)
        @namespace = namespace
        @user = user
      end

      def prefix
        @namespace.prefix
      end

      def uri
        @namespace.uri
      end

      def label
        @namespace.label(I18n.locale) || @namespace.label
      end

      def description
        @namespace.description(I18n.locale) || @namespace.description
      end

      def index_url
        prepend_url_context(xmp_namespaces_path)
      end

      def template_url
        prepend_url_context(xmp_namespace_path(prefix, format: :xmp))
      end

      def properties
        @namespace.xmp_properties.map do |property|
          {
            name: property.name,
            qualified_name: property.qualified_name,
            exiftool_key: property.exiftool_key,
            value_type: property.value_type,
            label: property.label(I18n.locale) || property.label,
            description: property.description(I18n.locale) || property.description,
            meta_keys: mapped_meta_keys.fetch(property.id, [])
          }
        end
      end

      private

      def mapped_meta_keys
        @_mapped_meta_keys ||= IoMapping
          .where(io_interface_id: 'default', xmp_property: @namespace.xmp_properties)
          .where(meta_key: MetaKey.viewable_by_user_or_public(@user))
          .includes(:meta_key)
          .group_by(&:xmp_property_id)
          .transform_values do |mappings|
            mappings.map do |mapping|
              meta_key = mapping.meta_key
              {
                id: meta_key.id,
                label: meta_key.label(I18n.locale) || meta_key.label,
                url: prepend_url_context(vocabulary_meta_key_path(meta_key))
              }
            end
          end
      end
    end
  end
end
