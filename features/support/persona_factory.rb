# coding: UTF-8

module PersonaFactory 
  extend self

  def create(persona)
    if FileTest.exist? "features/data/persona/#{persona.downcase}.rb"
      if Persona.get(persona).blank?
        require Rails.root+"features/data/persona/#{persona.downcase}.rb"
        Persona.const_get(persona.camelize).new
        puts "#{persona} was created"
      else
        puts "#{persona} was already created"
      end
    else 
      raise "Persona #{persona} does not exist"
    end
  end
end

puts " __            __     __   __    ___          __      __  __ __" 
puts "|_ \\_/ /\\ |\\/||__)|  |_   |  \\ /\\ |  /\\   |  /  \\ /\\ |  \\|_ |  \\" 
puts "|__/ \\/--\\|  ||   |__|__  |__//--\\| /--\\  |__\\__//--\\|__/|__|__/"
