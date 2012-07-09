# -*- encoding : utf-8 -*-
 
class MetaDatumCopyright < MetaDatum

  belongs_to :copyright

  def to_s
    value.to_s
  end

  def value
    copyright || Copyright.default
  end

  def value=(new_value)
    self.copyright =
      if new_value.is_a?(Copyright)
        new_value
      elsif new_value.is_a?(Fixnum) or (new_value.respond_to?(:is_integer?) and new_value.is_integer?)
        Copyright.find(new_value)
      else
        case new_value
        when true
          Copyright.custom
        when false
          Copyright.public
        else
          Copyright.default
        end
      end
  end
end
