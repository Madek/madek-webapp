module Presenters
  module MediaEntries
    class MediaEntryEmbedded < Presenters::Shared::AppResource

      include Presenters::MediaEntries::Modules::MediaEntryCommon

      def initialize(app_resource, config)
        raise TypeError unless config.is_a?(Hash)
        super(app_resource, nil) # MediaEntryCommon!
        @embed_config = config
      end

      attr_reader :embed_config

      def caption_conf(resource = @app_resource)
        {
          title: title,
          link: url,
          subtitle: [
            resource.authors.presence,
            resource.copyright_notice.presence
          ].compact.join(' — ')
        }
      end

    end
  end
end
