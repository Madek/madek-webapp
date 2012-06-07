# -*- encoding : utf-8 -*-
 
class MetaDatumMetaTerms < MetaDatum
  has_and_belongs_to_many :meta_terms, 
    join_table: :meta_data_meta_terms, 
    foreign_key: :meta_datum_id, 
    association_foreign_key: :meta_term_id

  alias_attribute :value, :meta_terms
  alias_attribute :deserialized_value, :meta_terms

  def to_s
    people.map(&:to_s).join("; ")
  end

end


