# -*- encoding : utf-8 -*-

class MetaDatumDepartments < MetaDatum
  has_and_belongs_to_many :meta_departments, 
    join_table: :meta_data_meta_departments,
    foreign_key: :meta_datum_id,
    association_foreign_key: :meta_department_id
 
  def to_s
    deserialized_value.map(&:to_s).join("; ")
  end

  def value
    meta_departments
  end

  def value=(new_value)
    new_meta_departments = Array(new_value).map do |v|
      if v.is_a?(Fixnum) or (v.respond_to?(:is_integer?) and v.is_integer?)
        MetaDepartment.find_by_id(v)
      elsif v.is_a?(String)
        MetaDepartment.by_string(v).first
      else
        v
      end
    end
    meta_departments.clear
    meta_departments << new_meta_departments.compact
  end

end
