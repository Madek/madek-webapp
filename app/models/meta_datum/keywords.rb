class MetaDatum::Keywords < MetaDatum
  has_many :keywords, foreign_key: :meta_datum_id
  has_many :keyword_terms, through: :keywords

  def to_s
    value.map(&:to_s).join('; ')
  end

  alias_method :value, :keyword_terms

  def value=(keyword_terms)
    with_sanitized keyword_terms do |keyword_terms|
      self.keyword_terms.clear
      self.keyword_terms = keyword_terms
    end
  end
end
