# -*- encoding : utf-8 -*-
 
class MetaDatumMetaTerms < MetaDatum
  has_and_belongs_to_many :meta_terms, 
    join_table: :meta_data_meta_terms, 
    foreign_key: :meta_datum_id, 
    association_foreign_key: :meta_term_id

  SEPARATOR = "; "

  def to_s
    value.map(&:to_s).join(SEPARATOR)
  end

  def value
    meta_terms
  end

  def value=(new_value)    
    new_meta_terms = Array(new_value).flat_map do |v|
      if v.is_a?(MetaTerm)
        v
      elsif v.is_a?(Fixnum) or (v.respond_to?(:is_integer?) and v.is_integer?)
        # TODO check if is member of meta_key.meta_terms
        MetaTerm.find_by_id(v)
      elsif meta_key.is_extensible_list?
        h = {}
        LANGUAGES.each {|lang| h[lang] = v}
        term = MetaTerm.find_or_initialize_by_en_gb_and_de_ch(h)
        meta_key.meta_terms << term unless meta_key.meta_terms.include?(term)
        term
      elsif v.is_a?(String) # the meta_key is not extensible list
        h = {}
        LANGUAGES.each {|lang| h[lang] = v}
        r = meta_key.meta_terms.where(h).first
        r ||= v.split(SEPARATOR).map do |vv| # reconvert string to array, in case reimporting previously exported media_resources
          h = {}
          LANGUAGES.each {|lang| h[lang] = vv}
          meta_key.meta_terms.where(h).first
        end
        r
      else
        v
      end
    end
    
    if new_meta_terms.include? nil
      # TODO add to errors doesn't persist
      #errors.add(:value)
      #media_resource.errors.add(:meta_data)
      raise "invalid value"
    else
      meta_terms.clear
      meta_terms << new_meta_terms
    end
  end

end


