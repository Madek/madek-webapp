class MetaKey < ActiveRecord::Base

  include Concerns::MetaKeys::Filters

  has_many :meta_data, dependent: :destroy
  has_many :vocables
  belongs_to :vocabulary

  default_scope { order(:id) }
  scope :with_vocables_count, lambda {
    joins('LEFT OUTER JOIN vocables ON vocables.meta_key_id = meta_keys.id')
      .select('meta_keys.*, count(vocables.id) as vocables_count')
      .group('meta_keys.id')
  }

  def self.object_types
    unscoped \
      .select('DISTINCT meta_datum_object_type')
      .order(:meta_datum_object_type)
      .map(&:meta_datum_object_type)
  end

  def can_have_vocables?
    meta_datum_object_type == 'MetaDatum::Vocables'
  end

end
