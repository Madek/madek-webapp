class KeywordTerm < ActiveRecord::Base
  include KeywordTermModules::TextSearch

  belongs_to :creator, class_name: User
  has_many :keywords

  scope :with_count, -> {
    joins("LEFT OUTER JOIN keywords ON keywords.keyword_term_id = keyword_terms.id") \
      .select("keyword_terms.*, count(keywords.id) AS keywords_count") \
      .group("keyword_terms.id")
  }

  scope :with_users_count, -> {
    joins("LEFT OUTER JOIN keywords ON keywords.keyword_term_id = keyword_terms.id") \
      .select("keyword_terms.*, count(DISTINCT(keywords.user_id)) AS users_count") \
      .group("keyword_terms.id")
  }

  scope :with_date_of_creation, -> {
    joins("LEFT OUTER JOIN keywords ON keywords.keyword_term_id = keyword_terms.id") \
      .select("keyword_terms.*, MIN(keywords.created_at) AS date_of_creation") \
      .group("keyword_terms.id")
  }

  def self.with_creators(search_term)
    joins("LEFT OUTER JOIN users ON keyword_terms.creator_id = users.id") \
      .where("users.searchable ILIKE :term", {term: "%#{search_term}%"}) \
      .group("keyword_terms.id")
  end

  def to_s
    term
  end

  def used_times
    keywords.count
  end

  def formatted_created_at
    date_of_creation.in_time_zone.to_s(:long)
  rescue
    "<em>not available</em>".html_safe
  end
end
