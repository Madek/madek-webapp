class KeywordTerm < ActiveRecord::Base
  include KeywordTermModules::TextSearch

  has_many :keywords

  scope :with_count, -> {
    joins("LEFT OUTER JOIN keywords ON keywords.keyword_term_id = keyword_terms.id").select("keyword_terms.*, count(keywords.id) AS keywords_count").group("keyword_terms.id")
  }

  def to_s
    term
  end

  def used_times
    keywords.count
  end
end
