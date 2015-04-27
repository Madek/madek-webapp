class MetaDatum::Licenses < MetaDatum
  has_and_belongs_to_many :licenses,
                          join_table: :meta_data_licenses,
                          foreign_key: :meta_datum_id,
                          association_foreign_key: :license_id

  alias_method :value, :licenses

  def value=(licenses)
    self.licenses.clear
    self.licenses = licenses
  end

end
