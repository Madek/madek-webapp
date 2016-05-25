module Presenters
  module Collections
    class CollectionEditMetaData \
      < Presenters::Shared::MediaResource::MediaResourceEdit

      include Presenters::Collections::Modules::CollectionCommon
    end
  end
end
