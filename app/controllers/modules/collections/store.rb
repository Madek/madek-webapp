module Modules
  module Collections
    module Store
      extend ActiveSupport::Concern

      private

      def store_collection(title)
        collection = Collection.create!(
          responsible_user: current_user,
          creator: current_user)
        meta_key = MetaKey.find_by(id: 'madek_core:title')
        MetaDatum::Text.create!(
          collection: collection,
          string: title,
          meta_key: meta_key,
          created_by: current_user)
        collection
      end

    end
  end
end
