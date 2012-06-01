# -*- encoding : utf-8 -*-
 
class MetaDatumPeople < MetaDatumBase
  has_and_belongs_to_many :people, 
    join_table: :meta_data_people, 
    foreign_key: :meta_datum_id, 
    association_foreign_key: :person_id

  alias_attribute :value, :people
  alias_attribute :deserialized_value, :people

  def to_s
    value.map(&:to_s).join("; ")
  end

end


