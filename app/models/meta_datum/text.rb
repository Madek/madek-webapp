# -*- encoding : utf-8 -*-

class MetaDatum::Text < MetaDatum

  def value
    string
  end

  alias_method :to_s, :value

  def value=(new_value)
    with_sanitized new_value do |new_value|
      self.string = new_value
    end
  end

end
