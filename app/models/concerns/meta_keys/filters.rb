module Concerns
  module MetaKeys
    module Filters
      extend ActiveSupport::Concern

      included do
        scope :filter_by, lambda { |term|
          where(
            'meta_keys.id ILIKE :t OR meta_keys.label ILIKE :t',
            t: "%#{term}%"
          )
        }
        scope :with_type, lambda { |type|
          where(meta_datum_object_type: type)
        }
        scope :of_vocabulary, lambda { |vocabulary_id|
          joins(:vocabulary)
            .where('vocabularies.id = :t', t: vocabulary_id)
        }
      end
    end
  end
end
