# -*- encoding : utf-8 -*-
 
class MetaDatumKeywords < MetaDatum

  has_and_belongs_to_many :keywords, 
    join_table: :meta_data_keywords, 
    foreign_key: :meta_datum_id, 
    association_foreign_key: :keyword_id

  alias_attribute :value, :keywords
  alias_attribute :deserialized_value, :keywords

  def to_s
    people.map(&:to_s).join("; ")
  end

end


