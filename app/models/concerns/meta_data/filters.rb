module Concerns
  module MetaData
    module Filters
      extend ActiveSupport::Concern

      included do
        scope :with_id, -> (id) { where(id: id) }
        scope :with_string, lambda { |string|
          where(%("meta_data"."string" ILIKE :t), t: "%#{string}%")
        }
        scope :of_media_entry, lambda { |id|
          where(media_entry_id: id)
        }
        scope :of_collection, lambda { |id|
          where(collection_id: id)
        }
        scope :of_filter_set, lambda { |id|
          where(filter_set_id: id)
        }
      end
    end
  end
end
