# coding: UTF-8

module PersonaFactory 
  extend self

  def create(persona)
    Persona.const_get(persona.camelize).new
  end
end

puts `rake madek:reset`

PersonaFactory.create("Adam")
PersonaFactory.create("Normin")

puts " __            __     __   __    ___          __      __  __ __" 
puts "|_ \\_/ /\\ |\\/||__)|  |_   |  \\ /\\ |  /\\   |  /  \\ /\\ |  \\|_ |  \\" 
puts "|__/ \\/--\\|  ||   |__|__  |__//--\\| /--\\  |__\\__//--\\|__/|__|__/"
