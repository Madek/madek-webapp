class MetaDatum::Keywords < MetaDatum
  has_many :keywords

  def to_s
    value.map(&:to_s).join('; ')
  end

  alias_method :value, :keywords

end
