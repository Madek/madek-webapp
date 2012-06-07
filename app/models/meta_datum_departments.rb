# -*- encoding : utf-8 -*-

class MetaDatumDepartments < MetaDatum
  has_and_belongs_to_many :meta_departments, 
    class_name: MetaDepartment.name,
    join_table: :meta_data_meta_departments,
    foreign_key: :meta_datum_id,
    association_foreign_key: :meta_department_id
 
  alias_attribute :value, :meta_departments
  alias_attribute :deserialized_value, :meta_departments

  def to_s
    meta_departments.map(&:to_s).join("; ")
  end

end
