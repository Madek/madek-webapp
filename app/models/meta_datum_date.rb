# -*- encoding : utf-8 -*-
 
class MetaDatumDate < MetaDatum

  belongs_to :meta_date_from, class_name: MetaDate.name
  belongs_to :meta_date_to, class_name: MetaDate.name


  #alias :meta_date :meta_date_to

  def update_or_create_meta_date_by_date_time relation, date_time
    meta_date = self.send(relation) || MetaDate.new
    meta_date.timestamp = date_time
    meta_date.timezone = Time.zone.formatted_offset        
    meta_date.free_text = meta_date.timestamp.iso8601[0..9]
    update_attributes(relation.to_sym => meta_date)
  end

  def update_or_create_meta_date_by_free_text relation, free_text
    meta_date = self.send(relation) || MetaDate.new
    meta_date.timestamp = nil
    meta_date.timezone = nil
    meta_date.free_text = free_text
    update_attributes(relation.to_sym => meta_date)
  end

  def value= v
    begin
      
      res = v.split(" - ").map(&:strip).map{|dt| DateTime.parse dt}

      if res[0]
        update_or_create_meta_date_by_date_time(:meta_date_from, res[0]) 
      else
        meta_date_from.try(:destroy)
      end
      
      if res[1]
        update_or_create_meta_date_by_date_time(:meta_date_to, res[1]) 
      else
        meta_date_to.try(:destroy)
      end

    rescue # last resort store as free text
      update_or_create_meta_date_by_free_text(:meta_date_from, v)
      meta_date_to.try(:destroy)
    end
  end

  def value
    "VALUE for MetaDatumDate"
  end

  def set_value_before_save
  end

  def to_s
  end

end
