# -*- encoding : utf-8 -*-
 
class MetaDatumCopyright < MetaDatum

  belongs_to :copyright

  def to_s
    value.to_s
  end

  def value
    copyright
  end

  def value=(new_value)
    self.copyright = case new_value
      when true
        Copyright.custom
      when false
        Copyright.public
      else
        Copyright.default
    end
  end

end
