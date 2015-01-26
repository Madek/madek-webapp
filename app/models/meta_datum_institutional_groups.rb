# -*- encoding : utf-8 -*-

class MetaDatumInstitutionalGroups < MetaDatum
  has_and_belongs_to_many :institutional_groups, 
    join_table: :meta_data_institutional_groups,
    foreign_key: :meta_datum_id,
    association_foreign_key: :institutional_group_id
 
  def to_s
    value.map(&:to_s).join("; ")
  end

  def value
    institutional_groups.sort_by(&:institutional_group_name)
  end

  def value=(new_value)
    new_institutional_groups = Array(new_value).map do |v|
      if v.is_a?(InstitutionalGroup)
        v
      elsif UUID_V4_REGEXP.match v 
        InstitutionalGroup.find_by id: v
      elsif v.is_a?(String)
        InstitutionalGroup.by_string(v).first
      else
        v
      end
    end

    #old#
    institutional_groups.clear
    institutional_groups << new_institutional_groups.compact
    
    #new# FIXME test is failing because "Vertiefung Fotografie (DKM_FMK_BMK_VFO.alle)" is missing
=begin
    if new_institutional_groups.include? nil
      raise "invalid value"
    else
      institutional_groups.clear
      institutional_groups << new_institutional_groups
    end
=end
  end

end
