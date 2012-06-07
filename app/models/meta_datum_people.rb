# -*- encoding : utf-8 -*-
 
class MetaDatumPeople < MetaDatum
  has_and_belongs_to_many :people, 
    join_table: :meta_data_people, 
    foreign_key: :meta_datum_id, 
    association_foreign_key: :person_id

  alias_attribute :value, :people

  def to_s
    deserialized_value.map(&:to_s).join("; ")
  end

end


