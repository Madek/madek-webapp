module Presenters
  module Collections
    class CollectionIndexWithChildren < ::Presenters::MetaData::EditContextMetaData
      def initialize(app_resource, user)
        super(app_resource, user, nil, true)
      end

      def child_resources
        @app_resource.child_media_resources.map do |mr|
          x_presenterify(mr)
        end
      end

      private

      def x_presenterify(obj)
        obj = obj.cast_to_type
        case obj
        when MediaEntry
          Presenters::MetaData::EditContextMetaData.new(obj, @user, nil, true)
        when Collection
          self.class.new(obj, @user)
        else
          raise "object of #{obj.class} class not supporded!"
        end
      end
    end
  end
end
