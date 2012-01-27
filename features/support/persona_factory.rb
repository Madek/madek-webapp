# coding: UTF-8

module PersonaFactory 
  extend self

  def create(persona)
    
    if FileTest.exist? "features/data/persona/#{persona.downcase}.rb"
      if Persona.get(persona).blank?
        require Rails.root+"features/data/persona/#{persona.downcase}.rb"
        Persona.const_get persona.camelize
      else
        puts "#{persona} was already created"
      end
    else 
      raise "Persona #{persona} does not exist"
    end
  end
end

module Persona
  extend self
  
  def get(name)
    User.where(:login => name).first
  end
end

PersonaFactory.create("Normin")

puts " __            __     __   __    ___          __      __  __ __" 
puts "|_ \\_/ /\\ |\\/||__)|  |_   |  \\ /\\ |  /\\   |  /  \\ /\\ |  \\|_ |  \\" 
puts "|__/ \\/--\\|  ||   |__|__  |__//--\\| /--\\  |__\\__//--\\|__/|__|__/"