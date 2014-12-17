class MetaDatum::People < MetaDatum
  has_and_belongs_to_many :people,
                          join_table: :meta_data_people,
                          foreign_key: :meta_datum_id,
                          association_foreign_key: :person_id

  def to_s
    value.map(&:to_s).join('; ')
  end

  alias_method :value, :people

  def value=(people)
    # raise ArgumentError, "only enumerable of class person accepted " unless
    self.people.clear
    self.people = people
  end

end
