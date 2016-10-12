module Presenters
  module MetaKeys
    class VocabularyMetaKeyIndex < Presenters::MetaKeys::MetaKeyCommon

      def keywords_count(meta_key = @app_resource)
        meta_key.keywords.count
      end

      def mappings(meta_key = @app_resource)
        # TMP: only default mappings (other might be to specialized)
        IoMapping.where(io_interface: IoInterface.first, meta_key: meta_key)
          .map { |m| Presenters::IoMappings::IoMappingCommon.new(m) }
      end

    end
  end
end
