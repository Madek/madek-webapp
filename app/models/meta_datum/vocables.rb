class MetaDatum::Vocables < MetaDatum
  has_and_belongs_to_many :vocables,
                          join_table: :meta_data_vocables,
                          foreign_key: :meta_datum_id,
                          association_foreign_key: :vocable_id
end
