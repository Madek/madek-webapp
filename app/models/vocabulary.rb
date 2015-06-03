class Vocabulary < ActiveRecord::Base

  VIEW_PERMISSION_NAME = :view

  include Concerns::Entrust
  include Concerns::PermissionsAssociations
  include Concerns::Vocabularies::Visibility
  include Concerns::Vocabularies::Usability

  has_many :meta_keys, -> { order(:id) }
  has_many :keyword_terms,
           through: :meta_keys

  scope :filter_by, lambda { |term|
    where(
      'vocabularies.id ILIKE :t OR vocabularies.label ILIKE :t',
      t: "%#{term}%"
    )
  }
  scope :with_meta_keys_count, lambda {
    joins('LEFT OUTER JOIN meta_keys ON meta_keys.vocabulary_id = vocabularies.id')
      .select('vocabularies.*, count(meta_keys.id) AS meta_keys_count')
      .group('vocabularies.id')
  }
  scope :ids_for_filter, -> { order(:id).pluck(:id) }

  validates :id, presence: true

  def to_s
    id
  end
end
