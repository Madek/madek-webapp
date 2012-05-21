# -*- encoding : utf-8 -*-
 
class MetaDatumDate < MetaDatum

  belongs_to :meta_date_from, class_name: MetaDate.name
  belongs_to :meta_date_to, class_name: MetaDate.name

  def value= *args
  end
  
  def value
  end

  def set_value_before_save
  end

  def to_s
  end

end
