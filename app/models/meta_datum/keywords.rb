class MetaDatum::Keywords < MetaDatum
  has_many :keywords, foreign_key: :meta_datum_id

  def to_s
    value.map(&:to_s).join('; ')
  end

  alias_method :value, :keywords

end
