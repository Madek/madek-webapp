module Concerns
  module Vocabularies
    module Filters
      extend ActiveSupport::Concern

      included do
        scope :filter_by, lambda { |term|
          where(
            'vocabularies.id ILIKE :t OR vocabularies.label ILIKE :t',
            t: "%#{term}%"
          )
        }
        scope :ids_for_filter, -> { order(:id).pluck(:id) }
        scope :viewable_by_public, -> { where(enabled_for_public_view: true) }
      end
    end
  end
end
