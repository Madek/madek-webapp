module Persona
  extend self
  
  def get(name)
    User.where(:login => name.downcase).first
  end
end