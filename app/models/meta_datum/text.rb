# -*- encoding : utf-8 -*-

class MetaDatum::Text < MetaDatum

  def to_s
    value.to_s
  end

  def value(user=nil)
    string
  end

  def value=(new_value)
    self.string = new_value
  end

end
