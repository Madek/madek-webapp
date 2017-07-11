module Presenters
  module MetaData
    class MetaDatumEdit < Presenters::MetaData::MetaDatumCommon

      def initialize(app_resource, user)
        super(app_resource, user)
      end

      def url
        return unless @app_resource.id # new MDs, like for edit, dont have an URL!
        super
      end
    end
  end
end
