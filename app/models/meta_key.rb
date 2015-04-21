class MetaKey < ActiveRecord::Base

  include Concerns::MetaKeys::Filters

  has_many :meta_data, dependent: :destroy
  has_many :keyword_terms
  belongs_to :vocabulary

  default_scope { order(:id) }
  scope :with_keyword_terms_count, lambda {
    joins(
      'LEFT OUTER JOIN keyword_terms ON
       keyword_terms.meta_key_id = meta_keys.id'
      )
      .select('meta_keys.*, count(keyword_terms.id) as keyword_terms_count')
      .group('meta_keys.id')
  }

  def self.object_types
    unscoped \
      .select(:meta_datum_object_type)
      .distinct
      .order(:meta_datum_object_type)
      .map(&:meta_datum_object_type)
  end

  def can_have_keywords?
    meta_datum_object_type == 'MetaDatum::Keywords'
  end

end
