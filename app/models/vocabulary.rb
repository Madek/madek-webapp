class Vocabulary < ActiveRecord::Base

  ENTRUSTED_PERMISSION = :view
  include Concerns::Entrust

  has_many :meta_keys, -> { order(:id) }
  has_many :vocables, through: :meta_keys

  has_many :user_permissions,
           class_name: 'Permissions::VocabularyUserPermission'
  has_many :group_permissions,
           class_name: 'Permissions::VocabularyGroupPermission'
  has_many :api_client_permissions,
           class_name: 'Permissions::VocabularyApiClientPermission'

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
  scope :viewable_by_public, -> { where(enabled_for_public_view: true) }

  validates :id, presence: true

  def to_s
    id
  end

  def self.viewable_by_user(user)
    scope1 = viewable_by_public
    scope2 = entrusted_to_user(user)
    sql = "((#{scope1.to_sql}) UNION " \
           "(#{scope2.to_sql})) AS vocabularies"
    from(sql)
  end
end
