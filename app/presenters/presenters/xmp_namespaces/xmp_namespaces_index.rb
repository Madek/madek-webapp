module Presenters
  module XmpNamespaces
    class XmpNamespacesIndex < Presenter
      def namespaces
        XmpNamespace.managed.sorted.includes(:xmp_properties).map do |namespace|
          {
            prefix: namespace.prefix,
            uri: namespace.uri,
            label: namespace.label(I18n.locale) || namespace.label,
            properties_count: namespace.xmp_properties.size,
            url: prepend_url_context(xmp_namespace_path(namespace.prefix))
          }
        end
      end
    end
  end
end
