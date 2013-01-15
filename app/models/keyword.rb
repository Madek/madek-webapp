# -*- encoding : utf-8 -*-
class Keyword < ActiveRecord::Base
  include Concerns::ResourcesThroughPermissions
  
  belongs_to :meta_term
  belongs_to :user
  belongs_to :meta_datum

  validates_presence_of :meta_term # FIXME check after, :meta_datum
  validates_uniqueness_of :meta_term_id, :scope => :meta_datum_id

  #default_scope :include => :meta_term

  def to_s
    "#{meta_term}"
  end

  def self.with_count
    select("meta_term_id, COUNT(meta_term_id) AS count").group("keywords.meta_term_id").order("count DESC")
  end

  def self.with_count_for_user user = nil
    with_count.joins(:meta_datum => :media_resource).accessible_by_user user
  end

#######################################

  scope :search, lambda { |query|
    return scoped if query.blank?

    q = query.split.map{|s| "%#{s}%"}
    joins(:meta_term).where(MetaTerm.arel_table[DEFAULT_LANGUAGE].matches_all(q))
  }
  
end
