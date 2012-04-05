class String
  
  #tmp# (respond_to?(:match) and !!match(/\A[+-]?\d+\Z/))
  def is_integer?
    Integer(self)
    true 
  rescue 
    false
  end

  def is_float?
    Float(self)
    true 
  rescue 
    false
  end
end