# -*- encoding : utf-8 -*-
 
class MetaDatumString < MetaDatum

  alias_attribute :value, :string

  after_save do
    SQLHelper.execute_sql "UPDATE meta_data SET value = NULL where id = #{id}"
  end

  def deserialized_value(user = nil)
    # TODO super if meta_key.is_dynamic? # when MetaDatum is the superclass
    string
  end
  def to_s
    # TODO super # when MetaDatum is the superclass
    string
  end

end
