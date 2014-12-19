class MetaDatum::Groups < MetaDatum
  has_and_belongs_to_many :groups,
                          join_table: :meta_data_groups,
                          foreign_key: :meta_datum_id,
                          association_foreign_key: :group_id

  alias_method :value, :groups

  def value=(groups)
    self.groups.clear
    self.groups = groups
  end

end
