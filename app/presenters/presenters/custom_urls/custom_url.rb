module Presenters
  module CustomUrls
    class CustomUrl < Presenters::Shared::AppResource

      def initialize(custom_url)
        super(custom_url)
      end

      def uuid
        super
      end

      def created_at
        super
      end

      def primary?
        @app_resource.is_primary
      end

      def creator
        Presenters::Users::UserIndex.new(@app_resource.creator)
      end
    end
  end
end
