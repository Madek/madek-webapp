module Presenters
  module CustomUrls
    class CustomUrl < Presenters::Shared::AppResource

      def initialize(custom_url)
        super(custom_url)
        @parent_resource = determine_parent
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

      def url
        send "#{@parent_resource.model_name.singular}_path",
             @app_resource.id
      end

      def set_primary_custom_url
        send "set_primary_custom_url_#{@parent_resource.model_name.singular}_path",
             @parent_resource.id,
             @app_resource.id
      end

      private

      def determine_parent
        @app_resource.media_entry.presence ||
          @app_resource.collection
      end
    end
  end
end
