# -*- encoding : utf-8 -*-
class Keyword < ActiveRecord::Base

  # TODO WTFK is this doing HERE ? 
  include Concerns::ResourcesThroughPermissions
  
  belongs_to :user
  belongs_to :meta_datum
  belongs_to :keyword_term

  def to_s
    "#{keyword_term}"
  end

  def self.with_count
    select("keyword_term_id, COUNT(keyword_term_id) AS count").group("keywords.keyword_term_id").order("count DESC")
  end

  def self.with_count_for_accessible_media_resources user = nil
    with_count.joins(:meta_datum => :media_resource).accessible_by_user(user,:view)
  end

#######################################

  scope :search, lambda { |query|
    return scoped if query.blank?
    search_term= "%#{query}%"
    joins(:keyword_term).where("keyword_terms.term ilike ?","%#{query}%")
  }
  
end
