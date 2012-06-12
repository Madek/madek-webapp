# -*- encoding : utf-8 -*-
 
class MetaDatumString < MetaDatum

  alias_attribute :value, :string

  after_save do
    SQLHelper.execute_sql "UPDATE meta_data SET value = NULL where id = #{id}"
  end

  def to_s
    v = deserialized_value
    if v.is_a?(Hash) # NOTE this is not recursive
      v.map {|x,y| "#{x.to_s.classify}: #{y}"}.join(', ')
    else
      v
    end
  end

end
