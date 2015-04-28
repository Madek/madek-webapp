class MetaDatum::Users < MetaDatum
  has_and_belongs_to_many :users,
                          join_table: :meta_data_users,
                          foreign_key: :meta_datum_id,
                          association_foreign_key: :user_id

  def to_s
    value.map(&:to_s).join('; ')
  end

  alias_method :value, :users

  def value=(users)
    with_sanitized users do |users|
      self.users.clear
      self.users = users
    end
  end

end
