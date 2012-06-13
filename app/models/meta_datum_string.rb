# -*- encoding : utf-8 -*-
 
class MetaDatumString < MetaDatum

  def to_s
    v = deserialized_value
    if v.is_a?(Hash) # NOTE this is not recursive
      v.map {|x,y| "#{x.to_s.classify}: #{y}"}.join(', ')
    else
      v
    end
  end

  def value
    string
  end

  def value=(new_value)
    self.string = new_value
  end
  
end
