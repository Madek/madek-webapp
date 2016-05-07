module Presenters
  module Collections
    class CollectionEditMetaData \
      < Presenters::Shared::MediaResource::MediaResourceEdit

      include Presenters::Collections::Modules::CollectionCommon

      def meta_data
        Presenters::MetaData::MetaDataEdit.new(@app_resource, @user)
      end

    end
  end
end
