# -*- encoding : utf-8 -*-
 
class MetaDatumMetaTerms < MetaDatum
  has_and_belongs_to_many :meta_terms, 
    join_table: :meta_data_meta_terms, 
    foreign_key: :meta_datum_id, 
    association_foreign_key: :meta_term_id

  def to_s
    deserialized_value.map(&:to_s).join("; ")
  end

  def value
    meta_terms
  end

  def value=(new_value)
    values = Person.split(Array(value))
    values.map do |v|
        if v.is_a?(Fixnum) or (v.respond_to?(:is_integer?) and v.is_integer?)
          #tmp# r = Person.where(:id => v).first
        else
          firstname, lastname = Person.parse(v)
          # FIXME find_or_build_by...
          r = Person.find_or_create_by_firstname_and_lastname(:firstname => firstname, :lastname => lastname) if firstname or lastname
        end
    end
  end

end


