module Concerns
  module MediaEntries
    module Filters
      extend ActiveSupport::Concern

      included do
        scope :search_with, lambda { |term|
          if UUIDTools::UUID_REGEXP =~ term
            where(id: term)
          else
            joins(%(LEFT OUTER JOIN meta_data ON \
              "meta_data"."media_entry_id" = "media_entries"."id"))
              .where(%("meta_data"."meta_key_id" = 'madek:core:title'))
              .where(%("meta_data"."string" ILIKE :term), term: "%#{term}%")
              .group('"media_entries"."id"')
          end
        }
      end
    end
  end
end
