# -*- encoding : utf-8 -*-
 
class MetaDatumKeywords < MetaDatum

  has_many :keywords, foreign_key: :meta_datum_id

  alias_attribute :value, :keywords

  def to_s
    keywords.map(&:to_s).join("; ")
  end

end


