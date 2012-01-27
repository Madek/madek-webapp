module PersonaFactory 
  extend self

  def create(persona)
    case persona
      when "Normin"
        name = "Normin"
        person = Factory(:person, :firstname => name)
        user = Factory(:user, :person => person, :login => name)
        sets = [] << Factory(:media_set, :user => user)
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