module Persona
  extend self
  
  def get(name)
    User.where(:login => name).first
  end
end
