module Presenters
  module MetaKeys
    class MetaKeyIndex < Presenters::MetaKeys::MetaKeyEdit
      # NOTE: this is just to support the autocompleter
      # * add custom label
      # * re-export "MetaKeyEdit" under the name that is expected for search,
      #   luckily does not need to be configurable because its only used for editing

      def autocomplete_label
        voc = @app_resource.vocabulary
        "#{self.label} [#{voc.label}]"
      end
    end
  end
end
