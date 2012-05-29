# -*- encoding : utf-8 -*-
 
class MetaDatumPerson < MetaDatumBase
  has_and_belongs_to_many :people, 
    join_table: :meta_data_people, 
    foreign_key: :meta_datum_id, 
    association_foreign_key: :person_id
end


